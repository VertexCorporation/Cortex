"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.BlockingFunctionEvents = exports.TenantProjectState = exports.AgentProjectState = exports.ProjectState = exports.SIGNIN_METHOD_EMAIL_LINK = exports.PROVIDER_GAME_CENTER = exports.PROVIDER_CUSTOM = exports.PROVIDER_ANONYMOUS = exports.PROVIDER_PHONE = exports.PROVIDER_PASSWORD = void 0;
exports.encodeRefreshToken = encodeRefreshToken;
exports.decodeRefreshToken = decodeRefreshToken;
const utils_1 = require("./utils");
const cloudFunctions_1 = require("./cloudFunctions");
const errors_1 = require("./errors");
exports.PROVIDER_PASSWORD = "password";
exports.PROVIDER_PHONE = "phone";
exports.PROVIDER_ANONYMOUS = "anonymous";
exports.PROVIDER_CUSTOM = "custom";
exports.PROVIDER_GAME_CENTER = "gc.apple.com";
exports.SIGNIN_METHOD_EMAIL_LINK = "emailLink";
class ProjectState {
    constructor(projectId) {
        this.projectId = projectId;
        this.users = new Map();
        this.localIdForEmail = new Map();
        this.localIdForInitialEmail = new Map();
        this.localIdForPhoneNumber = new Map();
        this.localIdsForProviderEmail = new Map();
        this.userIdForProviderRawId = new Map();
        this.localIdForPasskeyCredentialId = new Map();
        this.oobs = new Map();
        this.verificationCodes = new Map();
        this.temporaryProofs = new Map();
        this.pendingLocalIds = new Set();
    }
    get projectNumber() {
        return "12345";
    }
    generateLocalId() {
        for (let i = 0; i < 10; i++) {
            const localId = (0, utils_1.randomId)(28);
            if (!this.users.has(localId) && !this.pendingLocalIds.has(localId)) {
                this.pendingLocalIds.add(localId);
                return localId;
            }
        }
        throw new Error("Cannot generate a random unique localId after 10 tries.");
    }
    createUserWithLocalId(localId, props) {
        if (this.users.has(localId)) {
            return undefined;
        }
        this.users.set(localId, {
            localId,
        });
        this.pendingLocalIds.delete(localId);
        const user = this.updateUserByLocalId(localId, props, {
            upsertProviders: props.providerUserInfo,
        });
        this.authCloudFunction.dispatch("create", user);
        return user;
    }
    overwriteUserWithLocalId(localId, props) {
        const userInfoBefore = this.users.get(localId);
        if (userInfoBefore) {
            this.removeUserFromIndex(userInfoBefore);
        }
        const timestamp = new Date();
        this.users.set(localId, {
            localId,
            createdAt: props.createdAt || timestamp.getTime().toString(),
            lastLoginAt: timestamp.getTime().toString(),
        });
        const user = this.updateUserByLocalId(localId, props, {
            upsertProviders: props.providerUserInfo,
        });
        return user;
    }
    deleteUser(user) {
        this.users.delete(user.localId);
        this.removeUserFromIndex(user);
        this.authCloudFunction.dispatch("delete", user);
    }
    updateUserByLocalId(localId, fields, options = {}) {
        const upsertProviders = options.upsertProviders ?? [];
        const deleteProviders = options.deleteProviders ?? [];
        const user = this.users.get(localId);
        if (!user) {
            throw new Error(`Internal assertion error: trying to update nonexistent user: ${localId}`);
        }
        const oldEmail = user.email;
        const oldPhoneNumber = user.phoneNumber;
        const oldPasskeyInfo = user.passkeyInfo;
        for (const field of Object.keys(fields)) {
            (0, utils_1.mirrorFieldTo)(user, field, fields);
        }
        if (fields.passkeyInfo) {
            for (const pk of oldPasskeyInfo ?? []) {
                if (pk.credentialId) {
                    this.localIdForPasskeyCredentialId.delete(pk.credentialId);
                }
            }
            for (const pk of fields.passkeyInfo) {
                if (pk.credentialId) {
                    this.localIdForPasskeyCredentialId.set(pk.credentialId, user.localId);
                }
            }
        }
        if (oldEmail && oldEmail !== user.email) {
            this.localIdForEmail.delete(oldEmail);
        }
        if (user.email) {
            this.localIdForEmail.set(user.email, user.localId);
        }
        if (user.email && (user.passwordHash || user.emailLinkSignin)) {
            upsertProviders.push({
                providerId: exports.PROVIDER_PASSWORD,
                email: user.email,
                federatedId: user.email,
                rawId: user.email,
                displayName: user.displayName,
                photoUrl: user.photoUrl,
            });
        }
        else {
            deleteProviders.push(exports.PROVIDER_PASSWORD);
        }
        if (user.initialEmail) {
            this.localIdForInitialEmail.set(user.initialEmail, user.localId);
        }
        if (oldPhoneNumber && oldPhoneNumber !== user.phoneNumber) {
            this.localIdForPhoneNumber.delete(oldPhoneNumber);
        }
        if (user.phoneNumber) {
            this.localIdForPhoneNumber.set(user.phoneNumber, user.localId);
            upsertProviders.push({
                providerId: exports.PROVIDER_PHONE,
                phoneNumber: user.phoneNumber,
                rawId: user.phoneNumber,
            });
        }
        else {
            deleteProviders.push(exports.PROVIDER_PHONE);
        }
        if (user.mfaInfo) {
            this.validateMfaEnrollments(user.mfaInfo);
        }
        return this.updateUserProviderInfo(user, upsertProviders, deleteProviders);
    }
    validateMfaEnrollments(enrollments) {
        const phoneNumbers = new Set();
        const enrollmentIds = new Set();
        for (const enrollment of enrollments) {
            (0, errors_1.assert)(enrollment.phoneInfo && (0, utils_1.isValidPhoneNumber)(enrollment.phoneInfo), "INVALID_MFA_PHONE_NUMBER : Invalid format.");
            (0, errors_1.assert)(enrollment.mfaEnrollmentId, "INVALID_MFA_ENROLLMENT_ID : mfaEnrollmentId must be defined.");
            (0, errors_1.assert)(!enrollmentIds.has(enrollment.mfaEnrollmentId), "DUPLICATE_MFA_ENROLLMENT_ID");
            (0, errors_1.assert)(!phoneNumbers.has(enrollment.phoneInfo), "INTERNAL_ERROR : MFA Enrollment Phone Numbers must be unique.");
            phoneNumbers.add(enrollment.phoneInfo);
            enrollmentIds.add(enrollment.mfaEnrollmentId);
        }
        return enrollments;
    }
    updateUserProviderInfo(user, upsertProviders, deleteProviders) {
        const oldProviderEmails = getProviderEmailsForUser(user);
        if (user.providerUserInfo) {
            const updatedProviderUserInfo = [];
            for (const info of user.providerUserInfo) {
                if (deleteProviders.includes(info.providerId)) {
                    this.userIdForProviderRawId.get(info.providerId)?.delete(info.rawId);
                }
                else {
                    updatedProviderUserInfo.push(info);
                }
            }
            user.providerUserInfo = updatedProviderUserInfo;
        }
        if (upsertProviders.length) {
            user.providerUserInfo = user.providerUserInfo ?? [];
            for (const upsert of upsertProviders) {
                const providerId = upsert.providerId;
                let users = this.userIdForProviderRawId.get(providerId);
                if (!users) {
                    users = new Map();
                    this.userIdForProviderRawId.set(providerId, users);
                }
                users.set(upsert.rawId, user.localId);
                const index = user.providerUserInfo.findIndex((info) => info.providerId === upsert.providerId);
                if (index < 0) {
                    user.providerUserInfo.push(upsert);
                }
                else {
                    user.providerUserInfo[index] = upsert;
                }
            }
        }
        for (const email of getProviderEmailsForUser(user)) {
            oldProviderEmails.delete(email);
            let localIds = this.localIdsForProviderEmail.get(email);
            if (!localIds) {
                localIds = new Set();
                this.localIdsForProviderEmail.set(email, localIds);
            }
            localIds.add(user.localId);
        }
        for (const oldEmail of oldProviderEmails) {
            this.removeProviderEmailForUser(oldEmail, user.localId);
        }
        return user;
    }
    getUserByEmail(email) {
        const localId = this.localIdForEmail.get(email);
        if (!localId) {
            return undefined;
        }
        return this.getUserByLocalIdAssertingExists(localId);
    }
    getUserByInitialEmail(initialEmail) {
        const localId = this.localIdForInitialEmail.get(initialEmail);
        if (!localId) {
            return undefined;
        }
        return this.getUserByLocalIdAssertingExists(localId);
    }
    getUserByLocalIdAssertingExists(localId) {
        const userInfo = this.getUserByLocalId(localId);
        if (!userInfo) {
            throw new Error(`Internal state invariant broken: no user with ID: ${localId}`);
        }
        return userInfo;
    }
    getUsersByEmailOrProviderEmail(email) {
        const users = [];
        const seenLocalIds = new Set();
        const localId = this.localIdForEmail.get(email);
        if (localId) {
            users.push(this.getUserByLocalIdAssertingExists(localId));
            seenLocalIds.add(localId);
        }
        for (const localId of this.localIdsForProviderEmail.get(email) ?? []) {
            if (!seenLocalIds.has(localId)) {
                users.push(this.getUserByLocalIdAssertingExists(localId));
                seenLocalIds.add(localId);
            }
        }
        return users;
    }
    getUserByPhoneNumber(phoneNumber) {
        const localId = this.localIdForPhoneNumber.get(phoneNumber);
        if (!localId) {
            return undefined;
        }
        return this.getUserByLocalIdAssertingExists(localId);
    }
    removeProviderEmailForUser(email, localId) {
        const localIds = this.localIdsForProviderEmail.get(email);
        if (!localIds) {
            return;
        }
        localIds.delete(localId);
        if (localIds.size === 0) {
            this.localIdsForProviderEmail.delete(email);
        }
    }
    getUserByProviderRawId(provider, rawId) {
        const localId = this.userIdForProviderRawId.get(provider)?.get(rawId);
        if (!localId) {
            return undefined;
        }
        return this.getUserByLocalIdAssertingExists(localId);
    }
    listProviderInfosByProviderId(provider) {
        const users = this.userIdForProviderRawId.get(provider);
        if (!users) {
            return [];
        }
        const infos = [];
        for (const localId of users.values()) {
            const user = this.getUserByLocalIdAssertingExists(localId);
            const info = user.providerUserInfo?.find((info) => info.providerId === provider);
            if (!info) {
                throw new Error(`Internal assertion error: User ${localId} does not have providerInfo ${provider}.`);
            }
            infos.push(info);
        }
        return infos;
    }
    getUserByLocalId(localId) {
        return this.users.get(localId);
    }
    getUserByPasskeyCredentialId(credentialId) {
        const localId = this.localIdForPasskeyCredentialId.get(credentialId);
        if (!localId) {
            return undefined;
        }
        return this.getUserByLocalIdAssertingExists(localId);
    }
    createRefreshTokenFor(userInfo, provider, { extraClaims = {}, secondFactor, } = {}) {
        const localId = userInfo.localId;
        const refreshTokenRecord = {
            _AuthEmulatorRefreshToken: "DO NOT MODIFY",
            localId,
            provider,
            extraClaims,
            projectId: this.projectId,
            secondFactor,
            tenantId: userInfo.tenantId,
        };
        const refreshToken = encodeRefreshToken(refreshTokenRecord);
        return refreshToken;
    }
    validateRefreshToken(refreshToken) {
        const record = decodeRefreshToken(refreshToken);
        (0, errors_1.assert)(record.projectId === this.projectId, "INVALID_REFRESH_TOKEN");
        if (this instanceof TenantProjectState) {
            (0, errors_1.assert)(record.tenantId === this.tenantId, "TENANT_ID_MISMATCH");
        }
        const user = this.getUserByLocalId(record.localId);
        (0, errors_1.assert)(user, "INVALID_REFRESH_TOKEN");
        return {
            user,
            provider: record.provider,
            extraClaims: record.extraClaims,
            secondFactor: record.secondFactor,
        };
    }
    createOob(email, newEmail, requestType, generateLink) {
        const oobCode = (0, utils_1.randomBase64UrlStr)(54);
        const oobLink = generateLink(oobCode);
        const oob = {
            email,
            newEmail,
            requestType,
            oobCode,
            oobLink,
        };
        this.oobs.set(oobCode, oob);
        return oob;
    }
    validateOobCode(oobCode) {
        return this.oobs.get(oobCode);
    }
    deleteOobCode(oobCode) {
        return this.oobs.delete(oobCode);
    }
    listOobCodes() {
        return this.oobs.values();
    }
    createVerificationCode(phoneNumber) {
        const sessionInfo = (0, utils_1.randomBase64UrlStr)(226);
        const verification = {
            code: (0, utils_1.randomDigits)(6),
            phoneNumber,
            sessionInfo,
        };
        this.verificationCodes.set(sessionInfo, verification);
        return verification;
    }
    getVerificationCodeBySessionInfo(sessionInfo) {
        return this.verificationCodes.get(sessionInfo);
    }
    deleteVerificationCodeBySessionInfo(sessionInfo) {
        return this.verificationCodes.delete(sessionInfo);
    }
    listVerificationCodes() {
        return this.verificationCodes.values();
    }
    deleteAllAccounts() {
        this.users.clear();
        this.localIdForEmail.clear();
        this.localIdForPhoneNumber.clear();
        this.localIdsForProviderEmail.clear();
        this.userIdForProviderRawId.clear();
        this.localIdForPasskeyCredentialId.clear();
    }
    getUserCount() {
        return this.users.size;
    }
    queryUsers(filter, options) {
        const users = [];
        for (const user of this.users.values()) {
            if (!options.startToken || user.localId > options.startToken) {
                filter;
                users.push(user);
            }
        }
        users.sort((a, b) => {
            if (options.sortByField === "localId") {
                if (a.localId < b.localId) {
                    return -1;
                }
                else if (a.localId > b.localId) {
                    return 1;
                }
            }
            return 0;
        });
        return options.order === "DESC" ? users.reverse() : users;
    }
    createTemporaryProof(phoneNumber) {
        const record = {
            phoneNumber,
            temporaryProof: (0, utils_1.randomBase64UrlStr)(119),
            temporaryProofExpiresIn: "3600",
        };
        this.temporaryProofs.set(record.temporaryProof, record);
        return record;
    }
    validateTemporaryProof(temporaryProof, phoneNumber) {
        const record = this.temporaryProofs.get(temporaryProof);
        if (!record || record.phoneNumber !== phoneNumber) {
            return undefined;
        }
        return record;
    }
    removeUserFromIndex(user) {
        if (user.email) {
            this.localIdForEmail.delete(user.email);
        }
        if (user.initialEmail) {
            this.localIdForInitialEmail.delete(user.initialEmail);
        }
        if (user.phoneNumber) {
            this.localIdForPhoneNumber.delete(user.phoneNumber);
        }
        for (const info of user.providerUserInfo ?? []) {
            this.userIdForProviderRawId.get(info.providerId)?.delete(info.rawId);
            if (info.email) {
                this.removeProviderEmailForUser(info.email, user.localId);
            }
        }
        for (const pk of user.passkeyInfo ?? []) {
            if (pk.credentialId) {
                this.localIdForPasskeyCredentialId.delete(pk.credentialId);
            }
        }
    }
}
exports.ProjectState = ProjectState;
class AgentProjectState extends ProjectState {
    constructor(projectId) {
        super(projectId);
        this.tenantProjectForTenantId = new Map();
        this._authCloudFunction = new cloudFunctions_1.AuthCloudFunction(this.projectId);
        this._config = {
            signIn: { allowDuplicateEmails: false },
            blockingFunctions: {},
            emailPrivacyConfig: {
                enableImprovedEmailPrivacy: false,
            },
        };
    }
    get authCloudFunction() {
        return this._authCloudFunction;
    }
    get oneAccountPerEmail() {
        return !this._config.signIn.allowDuplicateEmails;
    }
    set oneAccountPerEmail(oneAccountPerEmail) {
        this._config.signIn.allowDuplicateEmails = !oneAccountPerEmail;
    }
    get enableImprovedEmailPrivacy() {
        return !!this._config.emailPrivacyConfig.enableImprovedEmailPrivacy;
    }
    set enableImprovedEmailPrivacy(improveEmailPrivacy) {
        this._config.emailPrivacyConfig.enableImprovedEmailPrivacy = improveEmailPrivacy;
    }
    get allowPasswordSignup() {
        return true;
    }
    get disableAuth() {
        return false;
    }
    get mfaConfig() {
        return { state: "ENABLED", enabledProviders: ["PHONE_SMS"] };
    }
    get enableAnonymousUser() {
        return true;
    }
    get enableEmailLinkSignin() {
        return true;
    }
    get config() {
        return this._config;
    }
    get blockingFunctionsConfig() {
        return this._config.blockingFunctions;
    }
    set blockingFunctionsConfig(blockingFunctions) {
        this._config.blockingFunctions = blockingFunctions;
    }
    shouldForwardCredentialToBlockingFunction(type) {
        switch (type) {
            case "accessToken":
                return this._config.blockingFunctions.forwardInboundCredentials?.accessToken ?? false;
            case "idToken":
                return this._config.blockingFunctions.forwardInboundCredentials?.idToken ?? false;
            case "refreshToken":
                return this._config.blockingFunctions.forwardInboundCredentials?.refreshToken ?? false;
        }
    }
    getBlockingFunctionUri(event) {
        const triggers = this.blockingFunctionsConfig.triggers;
        if (triggers) {
            return Object.prototype.hasOwnProperty.call(triggers, event)
                ? triggers[event].functionUri
                : undefined;
        }
        return undefined;
    }
    updateConfig(update, updateMask) {
        if (!updateMask) {
            this.oneAccountPerEmail = !update.signIn?.allowDuplicateEmails;
            this.blockingFunctionsConfig = update.blockingFunctions ?? {};
            this.enableImprovedEmailPrivacy =
                update.emailPrivacyConfig?.enableImprovedEmailPrivacy ?? false;
            return this.config;
        }
        return applyMask(updateMask, this.config, update);
    }
    getTenantProject(tenantId) {
        if (!this.tenantProjectForTenantId.has(tenantId)) {
            this.createTenantWithTenantId(tenantId, {
                tenantId,
                allowPasswordSignup: true,
                disableAuth: false,
                mfaConfig: {
                    state: "ENABLED",
                    enabledProviders: ["PHONE_SMS"],
                },
                enableAnonymousUser: true,
                enableEmailLinkSignin: true,
            });
        }
        return this.tenantProjectForTenantId.get(tenantId);
    }
    listTenants(startToken) {
        const tenantProjects = [];
        for (const tenantProject of this.tenantProjectForTenantId.values()) {
            if (!startToken || tenantProject.tenantId > startToken) {
                tenantProjects.push(tenantProject);
            }
        }
        tenantProjects.sort((a, b) => {
            if (a.tenantId < b.tenantId) {
                return -1;
            }
            else if (a.tenantId > b.tenantId) {
                return 1;
            }
            return 0;
        });
        return tenantProjects.map((tenantProject) => tenantProject.tenantConfig);
    }
    createTenant(tenant) {
        for (let i = 0; i < 10; i++) {
            const tenantId = (0, utils_1.randomId)(28);
            const createdTenant = this.createTenantWithTenantId(tenantId, tenant);
            if (createdTenant) {
                return createdTenant;
            }
        }
        throw new Error("Could not generate a random unique tenantId after 10 tries");
    }
    createTenantWithTenantId(tenantId, tenant) {
        if (this.tenantProjectForTenantId.has(tenantId)) {
            return undefined;
        }
        tenant.name = `projects/${this.projectId}/tenants/${tenantId}`;
        tenant.tenantId = tenantId;
        this.tenantProjectForTenantId.set(tenantId, new TenantProjectState(this.projectId, tenantId, tenant, this));
        return tenant;
    }
    deleteTenant(tenantId) {
        this.tenantProjectForTenantId.delete(tenantId);
    }
}
exports.AgentProjectState = AgentProjectState;
class TenantProjectState extends ProjectState {
    constructor(projectId, tenantId, _tenantConfig, parentProject) {
        super(projectId);
        this.tenantId = tenantId;
        this._tenantConfig = _tenantConfig;
        this.parentProject = parentProject;
    }
    get oneAccountPerEmail() {
        return this.parentProject.oneAccountPerEmail;
    }
    get enableImprovedEmailPrivacy() {
        return this.parentProject.enableImprovedEmailPrivacy;
    }
    get authCloudFunction() {
        return this.parentProject.authCloudFunction;
    }
    get tenantConfig() {
        return this._tenantConfig;
    }
    get allowPasswordSignup() {
        return this._tenantConfig.allowPasswordSignup;
    }
    get disableAuth() {
        return this._tenantConfig.disableAuth;
    }
    get mfaConfig() {
        return this._tenantConfig.mfaConfig;
    }
    get enableAnonymousUser() {
        return this._tenantConfig.enableAnonymousUser;
    }
    get enableEmailLinkSignin() {
        return this._tenantConfig.enableEmailLinkSignin;
    }
    shouldForwardCredentialToBlockingFunction(type) {
        return this.parentProject.shouldForwardCredentialToBlockingFunction(type);
    }
    getBlockingFunctionUri(event) {
        return this.parentProject.getBlockingFunctionUri(event);
    }
    delete() {
        this.parentProject.deleteTenant(this.tenantId);
    }
    updateTenant(update, updateMask) {
        if (!updateMask) {
            const mfaConfig = update.mfaConfig ?? {};
            if (!("state" in mfaConfig)) {
                mfaConfig.state = "DISABLED";
            }
            if (!("enabledProviders" in mfaConfig)) {
                mfaConfig.enabledProviders = [];
            }
            this._tenantConfig = {
                tenantId: this.tenantId,
                name: this.tenantConfig.name,
                allowPasswordSignup: update.allowPasswordSignup ?? false,
                disableAuth: update.disableAuth ?? false,
                mfaConfig: mfaConfig,
                enableAnonymousUser: update.enableAnonymousUser ?? false,
                enableEmailLinkSignin: update.enableEmailLinkSignin ?? false,
                displayName: update.displayName,
            };
            return this.tenantConfig;
        }
        return applyMask(updateMask, this.tenantConfig, update);
    }
}
exports.TenantProjectState = TenantProjectState;
var BlockingFunctionEvents;
(function (BlockingFunctionEvents) {
    BlockingFunctionEvents["BEFORE_CREATE"] = "beforeCreate";
    BlockingFunctionEvents["BEFORE_SIGN_IN"] = "beforeSignIn";
})(BlockingFunctionEvents || (exports.BlockingFunctionEvents = BlockingFunctionEvents = {}));
function encodeRefreshToken(refreshTokenRecord) {
    return Buffer.from(JSON.stringify(refreshTokenRecord), "utf8").toString("base64");
}
function decodeRefreshToken(refreshTokenString) {
    let refreshTokenRecord;
    try {
        const json = Buffer.from(refreshTokenString, "base64").toString("utf8");
        refreshTokenRecord = JSON.parse(json);
    }
    catch {
        throw new errors_1.BadRequestError("INVALID_REFRESH_TOKEN");
    }
    (0, errors_1.assert)(refreshTokenRecord._AuthEmulatorRefreshToken, "INVALID_REFRESH_TOKEN");
    return refreshTokenRecord;
}
function getProviderEmailsForUser(user) {
    const emails = new Set();
    user.providerUserInfo?.forEach(({ email }) => {
        if (email) {
            emails.add(email);
        }
    });
    return emails;
}
function applyMask(updateMask, dest, update) {
    const paths = updateMask.split(",");
    for (const path of paths) {
        const fields = path.split(".");
        let updateField = update;
        let existingField = dest;
        let field;
        for (let i = 0; i < fields.length - 1; i++) {
            field = fields[i];
            if (updateField[field] == null) {
                console.warn(`Unable to find field '${field}' in update '${updateField}`);
                break;
            }
            if (Array.isArray(updateField[field]) || Object(updateField[field]) !== updateField[field]) {
                console.warn(`Field '${field}' is singular and cannot have sub-fields`);
                break;
            }
            if (!existingField[field]) {
                existingField[field] = {};
            }
            updateField = updateField[field];
            existingField = existingField[field];
        }
        field = fields[fields.length - 1];
        if (updateField[field] == null) {
            console.warn(`Unable to find field '${field}' in update '${JSON.stringify(updateField)}`);
            continue;
        }
        existingField[field] = updateField[field];
    }
    return dest;
}
