import tls from 'node:tls';
import { AuthClient, GoogleAuth } from 'google-auth-library';
import { IpAddressTypes } from './ip-addresses';
import { AuthTypes } from './auth-types';
export declare interface UnixSocketOptions {
    path: string | undefined;
    readableAll?: boolean | undefined;
    writableAll?: boolean | undefined;
}
export declare interface ConnectionOptions {
    authType?: AuthTypes;
    ipType?: IpAddressTypes;
    instanceConnectionName: string;
    domainName?: string;
    failoverPeriod?: number;
    limitRateInterval?: number;
}
export declare interface SocketConnectionOptions extends ConnectionOptions {
    listenOptions: UnixSocketOptions;
}
interface StreamFunction {
    (): tls.TLSSocket;
}
interface PromisedStreamFunction {
    (): Promise<tls.TLSSocket>;
}
export declare interface DriverOptions {
    stream: StreamFunction;
}
export declare interface TediousDriverOptions {
    connector: PromisedStreamFunction;
    encrypt: boolean;
}
export interface ConnectorOptions {
    auth?: GoogleAuth<AuthClient> | AuthClient;
    sqlAdminAPIEndpoint?: string;
    /**
     * The Trusted Partner Cloud (TPC) Domain DNS of the service used to make requests.
     * Defaults to `googleapis.com`.
     */
    universeDomain?: string;
    userAgent?: string;
}
export declare class Connector {
    private readonly instances;
    private readonly sqlAdminFetcher;
    private readonly localProxies;
    private readonly sockets;
    constructor(opts?: ConnectorOptions);
    getOptions(opts: ConnectionOptions): Promise<DriverOptions>;
    getTediousOptions({ authType, ipType, instanceConnectionName, }: ConnectionOptions): Promise<TediousDriverOptions>;
    startLocalProxy({ authType, ipType, instanceConnectionName, listenOptions, }: SocketConnectionOptions): Promise<void>;
    close(): void;
}
export {};
//# sourceMappingURL=connector.d.ts.map