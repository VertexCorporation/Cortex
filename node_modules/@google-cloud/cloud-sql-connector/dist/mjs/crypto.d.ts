import { RSAKeys } from './rsa-keys.js';
import { SslCert } from './ssl-cert.js';
export declare function generateKeys(): Promise<RSAKeys>;
export declare function parseCert(cert: string): Promise<SslCert>;
//# sourceMappingURL=crypto.d.ts.map