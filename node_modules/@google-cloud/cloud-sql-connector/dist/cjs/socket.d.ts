import tls from 'node:tls';
import { InstanceConnectionInfo } from './instance-connection-info';
import { SslCert } from './ssl-cert';
interface SocketOptions {
    ephemeralCert: SslCert;
    host: string;
    port: number;
    instanceInfo: InstanceConnectionInfo;
    privateKey: string;
    serverCaCert: SslCert;
    instanceDnsName: string;
    serverName: string;
}
/**
 * validateCertificate implements custom TLS verification logic to gracefully and securely
 * handle deviations from standard TLS hostname verification in existing Cloud SQL instance server
 * certificates.
 *
 *
 * @param instanceInfo the instance connection name
 * @param instanceDnsName the instance's DNS name according to instance metadata
 * @param serverName the dns name from the connector configuration.
 *
 * This is run AFTER the NodeJS TLS library has validated the CA for the
 * server certificate.
 *
 * <p>This is the verification algorithm:
 *
 * <ol>
 *   <li>Verify the server cert CA, using the CA certs from the instance metadata. Reject the
 *       certificate if the CA is invalid.
 *   <li>Check that the server cert contains a SubjectAlternativeName matching the DNS name in the
 *       connector configuration OR the DNS Name from the instance metadata
 *   <li>If the SubjectAlternativeName does not match, and if the server cert Subject.CN field is
 *       not empty, check that the Subject.CN field contains the instance name. Reject the
 *       certificate if both the #2 SAN check and #3 CN checks fail.
 * </ol>
 *
 * <p>To summarize the deviations from standard TLS hostname verification:
 *
 * <p>Historically, Cloud SQL creates server certificates with the instance name in the Subject.CN
 * field in the format "my-project:my-instance". The connector is expected to check that the
 * instance name that the connector was configured to dial matches the server certificate Subject.CN
 * field. Thus, the Subject.CN field for most Cloud SQL instances does not contain a well-formed DNS
 * Name. This breaks standard TLS hostname verification.
 *
 * <p>Also, there are times when the instance metadata reports that an instance has a DNS name, but
 * that DNS name does not yet appear in the SAN records of the server certificate. The client should
 * fall back to validating the hostname using the instance name in the Subject.CN field.
 */
export declare function validateCertificate(instanceInfo: InstanceConnectionInfo, instanceDnsName: string, serverName: string): (hostname: string, cert: tls.PeerCertificate) => Error | undefined;
export declare function getSocket({ ephemeralCert, host, port, instanceInfo, privateKey, serverCaCert, instanceDnsName, serverName, }: SocketOptions): tls.TLSSocket;
export {};
//# sourceMappingURL=socket.d.ts.map