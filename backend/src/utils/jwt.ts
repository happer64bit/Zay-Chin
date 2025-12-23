import { SignJWT, jwtVerify } from 'jose'
import { env } from './env'

const accessTokenSecret = new TextEncoder().encode(
    env.ACCESS_JWT_SECRET
)

const refreshTokenSecret = new TextEncoder().encode(
    env.REFRESH_JWT_SECRET
)

export async function signAccessToken(sub: string) {
    return await new SignJWT()
        .setProtectedHeader({
            alg: 'HS256'
        })
        .setIssuedAt()
        .setSubject(sub)
        .setIssuer('urn:famcart')
        .setAudience('urn:famcart')
        .setExpirationTime('15m')
        .sign(accessTokenSecret)
}

export function signRefreshToken(sub: string) {
    return new SignJWT()
        .setProtectedHeader({
            alg: 'HS256'
        })
        .setIssuedAt()
        .setSubject(sub)
        .setIssuer('urn:famcart')
        .setAudience('urn:famcart')
        .setExpirationTime('7d')
        .sign(refreshTokenSecret)
}

export async function verifyAccessToken(token: string) {
    return await jwtVerify(token, accessTokenSecret, {
        issuer: 'urn:famcart',
        audience: 'urn:famcart'
    })
}

export async function verifyRefreshToken(token: string) {
    return await jwtVerify(token, refreshTokenSecret, {
        issuer: 'urn:famcart',
        audience: 'urn:famcart'
    })
}
