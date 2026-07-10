"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CLOUDSQL_SUPER_USER = exports.FIREBASE_SUPER_USER = exports.DEFAULT_SCHEMA = void 0;
exports.firebaseowner = firebaseowner;
exports.firebasereader = firebasereader;
exports.firebasewriter = firebasewriter;
exports.ownerRolePermissions = ownerRolePermissions;
exports.writerRolePermissions = writerRolePermissions;
exports.readerRolePermissions = readerRolePermissions;
exports.defaultPermissions = defaultPermissions;
exports.DEFAULT_SCHEMA = "public";
exports.FIREBASE_SUPER_USER = "firebasesuperuser";
exports.CLOUDSQL_SUPER_USER = "cloudsqlsuperuser";
function firebaseowner(databaseId, schema = exports.DEFAULT_SCHEMA) {
    return `firebaseowner_${databaseId}_${schema}`;
}
function firebasereader(databaseId, schema = exports.DEFAULT_SCHEMA) {
    return `firebasereader_${databaseId}_${schema}`;
}
function firebasewriter(databaseId, schema = exports.DEFAULT_SCHEMA) {
    return `firebasewriter_${databaseId}_${schema}`;
}
function ownerRolePermissions(databaseId, superuser, schema) {
    const firebaseOwnerRole = firebaseowner(databaseId, schema);
    return [
        `do
      $$
      begin
        if not exists (select FROM pg_catalog.pg_roles
          WHERE  rolname = '${firebaseOwnerRole}') then
          CREATE ROLE "${firebaseOwnerRole}" WITH ADMIN "${superuser}";
        end if;
      end
      $$
    ;`,
        `GRANT "${firebaseOwnerRole}" TO "cloudsqlsuperuser"`,
        `ALTER SCHEMA "${schema}" OWNER TO "${firebaseOwnerRole}"`,
        `GRANT USAGE ON SCHEMA "${schema}" TO "${firebaseOwnerRole}"`,
        `GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA "${schema}" TO "${firebaseOwnerRole}"`,
        `GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA "${schema}" TO "${firebaseOwnerRole}"`,
    ];
}
function writerRolePermissions(databaseId, superuser, schema) {
    const firebaseWriterRole = firebasewriter(databaseId, schema);
    return [
        `do
      $$
      begin
        if not exists (select FROM pg_catalog.pg_roles
          WHERE  rolname = '${firebaseWriterRole}') then
          CREATE ROLE "${firebaseWriterRole}" WITH ADMIN "${superuser}";
        end if;
      end
      $$
    ;`,
        `GRANT "${firebaseWriterRole}" TO "cloudsqlsuperuser"`,
        `GRANT USAGE ON SCHEMA "${schema}" TO "${firebaseWriterRole}"`,
        `GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA "${schema}" TO "${firebaseWriterRole}"`,
        `GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA "${schema}" TO "${firebaseWriterRole}"`,
        `GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA "${schema}" TO "${firebaseWriterRole}"`,
    ];
}
function readerRolePermissions(databaseId, superuser, schema) {
    const firebaseReaderRole = firebasereader(databaseId, schema);
    return [
        `do
      $$
      begin
        if not exists (select FROM pg_catalog.pg_roles
          WHERE  rolname = '${firebaseReaderRole}') then
          CREATE ROLE "${firebaseReaderRole}" WITH ADMIN "${superuser}";
        end if;
      end
      $$
    ;`,
        `GRANT "${firebaseReaderRole}" TO "cloudsqlsuperuser"`,
        `GRANT USAGE ON SCHEMA "${schema}" TO "${firebaseReaderRole}"`,
        `GRANT SELECT ON ALL TABLES IN SCHEMA "${schema}" TO "${firebaseReaderRole}"`,
        `GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA "${schema}" TO "${firebaseReaderRole}"`,
        `GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA "${schema}" TO "${firebaseReaderRole}"`,
    ];
}
function defaultPermissions(databaseId, schema, ownerRole) {
    const firebaseWriterRole = firebasewriter(databaseId, schema);
    const firebaseReaderRole = firebasereader(databaseId, schema);
    return [
        `ALTER DEFAULT PRIVILEGES
      FOR ROLE "${ownerRole}"
      IN SCHEMA "${schema}"
      GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLES TO "${firebaseWriterRole}";`,
        `ALTER DEFAULT PRIVILEGES
      FOR ROLE "${ownerRole}"
      IN SCHEMA "${schema}"
      GRANT USAGE ON SEQUENCES TO "${firebaseWriterRole}";`,
        `ALTER DEFAULT PRIVILEGES
      FOR ROLE "${ownerRole}"
      IN SCHEMA "${schema}"
      GRANT EXECUTE ON FUNCTIONS TO "${firebaseWriterRole}";`,
        `ALTER DEFAULT PRIVILEGES
      FOR ROLE "${ownerRole}"
      IN SCHEMA "${schema}"
      GRANT SELECT ON TABLES TO "${firebaseReaderRole}";`,
        `ALTER DEFAULT PRIVILEGES
      FOR ROLE "${ownerRole}"
      IN SCHEMA "${schema}"
      GRANT USAGE ON SEQUENCES TO "${firebaseReaderRole}";`,
        `ALTER DEFAULT PRIVILEGES
      FOR ROLE "${ownerRole}"
      IN SCHEMA "${schema}"
      GRANT EXECUTE ON FUNCTIONS TO "${firebaseReaderRole}";`,
    ];
}
