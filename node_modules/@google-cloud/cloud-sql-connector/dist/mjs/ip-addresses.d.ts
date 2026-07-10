export declare enum IpAddressTypes {
    PUBLIC = "PUBLIC",
    PRIVATE = "PRIVATE",
    PSC = "PSC"
}
export declare interface IpAddresses {
    public?: string;
    private?: string;
    psc?: string;
}
export declare function selectIpAddress(ipAddresses: IpAddresses, type: IpAddressTypes | unknown): string;
//# sourceMappingURL=ip-addresses.d.ts.map