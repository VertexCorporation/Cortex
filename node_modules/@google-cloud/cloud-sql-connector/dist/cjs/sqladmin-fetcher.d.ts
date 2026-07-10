import { AuthClient, GoogleAuth } from 'google-auth-library';
import { InstanceConnectionInfo } from './instance-connection-info';
import { SslCert } from './ssl-cert';
import { IpAddresses } from './ip-addresses';
import { AuthTypes } from './auth-types';
export interface InstanceMetadata {
    ipAddresses: IpAddresses;
    serverCaCert: SslCert;
    serverCaMode: string;
    dnsName: string;
}
export interface SQLAdminFetcherOptions {
    loginAuth?: GoogleAuth<AuthClient> | AuthClient;
    sqlAdminAPIEndpoint?: string;
    universeDomain?: string;
    userAgent?: string;
}
export declare class SQLAdminFetcher {
    private readonly client;
    private readonly auth;
    constructor({ loginAuth, sqlAdminAPIEndpoint, universeDomain, userAgent, }?: SQLAdminFetcherOptions);
    private parseIpAddresses;
    getInstanceMetadata({ projectId, regionId, instanceId, }: InstanceConnectionInfo): Promise<InstanceMetadata>;
    getEphemeralCertificate({ projectId, instanceId }: InstanceConnectionInfo, publicKey: string, authType: AuthTypes): Promise<SslCert>;
}
//# sourceMappingURL=sqladmin-fetcher.d.ts.map