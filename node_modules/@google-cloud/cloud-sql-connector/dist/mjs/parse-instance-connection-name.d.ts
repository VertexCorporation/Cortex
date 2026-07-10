import { InstanceConnectionInfo } from './instance-connection-info.js';
export declare function isSameInstance(a: InstanceConnectionInfo, b: InstanceConnectionInfo): boolean;
export declare function resolveInstanceName(instanceConnectionName?: string, domainName?: string): Promise<InstanceConnectionInfo>;
export declare function isValidDomainName(name: string): boolean;
export declare function isInstanceConnectionName(name: string): boolean;
export declare function resolveDomainName(name: string): Promise<InstanceConnectionInfo>;
export declare function parseInstanceConnectionName(instanceConnectionName: string | undefined): InstanceConnectionInfo;
//# sourceMappingURL=parse-instance-connection-name.d.ts.map