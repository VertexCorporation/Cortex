import { IpAddressTypes } from './ip-addresses.js';
import { InstanceConnectionInfo } from './instance-connection-info.js';
import { InstanceMetadata } from './sqladmin-fetcher.js';
import { SslCert } from './ssl-cert.js';
import { AuthTypes } from './auth-types.js';
type EventFn = () => void;
type DestroyableSocket = {
    destroy: (error?: Error) => void;
    once: (name: string, handler: EventFn) => void;
};
interface Fetcher {
    getInstanceMetadata({ projectId, regionId, instanceId, }: InstanceConnectionInfo): Promise<InstanceMetadata>;
    getEphemeralCertificate(instanceConnectionInfo: InstanceConnectionInfo, publicKey: string, authType: AuthTypes): Promise<SslCert>;
}
interface CloudSQLInstanceOptions {
    authType: AuthTypes;
    instanceConnectionName: string;
    domainName?: string;
    ipType: IpAddressTypes;
    limitRateInterval?: number;
    sqlAdminFetcher: Fetcher;
    failoverPeriod?: number;
}
interface RefreshResult {
    ephemeralCert: SslCert;
    host: string;
    privateKey: string;
    serverCaCert: SslCert;
}
export declare class CloudSQLInstance {
    static getCloudSQLInstance(options: CloudSQLInstanceOptions): Promise<CloudSQLInstance>;
    private readonly ipType;
    private readonly authType;
    private readonly sqlAdminFetcher;
    private readonly limitRateInterval;
    private establishedConnection;
    private next?;
    private scheduledRefreshID?;
    private checkDomainID?;
    private throttle?;
    private closed;
    private failoverPeriod;
    private sockets;
    readonly instanceInfo: InstanceConnectionInfo;
    ephemeralCert?: SslCert;
    host?: string;
    port: number;
    privateKey?: string;
    serverCaCert?: SslCert;
    serverCaMode: string;
    dnsName: string;
    constructor({ options, instanceInfo, }: {
        options: CloudSQLInstanceOptions;
        instanceInfo: InstanceConnectionInfo;
    });
    private initializeRateLimiter;
    forceRefresh(): Promise<void>;
    refresh(): Promise<RefreshResult>;
    private performRefresh;
    private isValid;
    private updateValues;
    private scheduleRefresh;
    cancelRefresh(): void;
    setEstablishedConnection(): void;
    close(): void;
    isClosed(): boolean;
    checkDomainChanged(): Promise<void>;
    addSocket(socket: DestroyableSocket): void;
}
export {};
//# sourceMappingURL=cloud-sql-instance.d.ts.map