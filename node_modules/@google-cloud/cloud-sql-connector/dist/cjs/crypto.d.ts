import { RSAKeys } from './rsa-keys';
import { SslCert } from './ssl-cert';
export declare function generateKeys(): Promise<RSAKeys>;
export declare function parseCert(cert: string): Promise<SslCert>;
//# sourceMappingURL=crypto.d.ts.map