import { serve } from "https://deno.land/std@0.201.0/http/server.ts";

const PROJECT_ID = Deno.env.get("FCM_PROJECT_ID");
const CLIENT_EMAIL = Deno.env.get("FCM_CLIENT_EMAIL");
const PRIVATE_KEY = Deno.env.get("FCM_PRIVATE_KEY");

function base64url(input: string) {
  return btoa(input).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

async function getAccessToken(): Promise<string | null> {
  if (!CLIENT_EMAIL || !PRIVATE_KEY) {
    console.error('Missing CLIENT_EMAIL or PRIVATE_KEY env vars');
    return null;
  }
  const now = Math.floor(Date.now() / 1000);
  const jwtHeader = { alg: "RS256", typ: "JWT" };
  const jwtClaimSet = {
    iss: CLIENT_EMAIL,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    exp: now + 3600,
    iat: now,
  };

  const unsignedToken = `${base64url(JSON.stringify(jwtHeader))}.${base64url(JSON.stringify(jwtClaimSet))}`;

  // Prepare private key bytes (expect PRIVATE_KEY in PEM format)
  const pem = PRIVATE_KEY.replace(/-----[^-]+-----/g, "").replace(/\s+/g, "");
  const keyRaw = atob(pem);
  const keyData = new Uint8Array(keyRaw.length);
  for (let i = 0; i < keyRaw.length; i++) keyData[i] = keyRaw.charCodeAt(i);

  const key = await crypto.subtle.importKey(
    "pkcs8",
    keyData.buffer,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );

  const encoder = new TextEncoder();
  const signatureBuffer = await crypto.subtle.sign("RSASSA-PKCS1-v1_5", key, encoder.encode(unsignedToken));

  // convert signature to base64url
  const sigBytes = new Uint8Array(signatureBuffer);
  let sigBinary = "";
  for (let i = 0; i < sigBytes.byteLength; i++) sigBinary += String.fromCharCode(sigBytes[i]);
  const signatureB64 = btoa(sigBinary);
  const signedToken = `${unsignedToken}.${signatureB64.replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "")}`;

  // Exchange JWT for access_token
  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${signedToken}`,
  });
  if (!res.ok) {
    console.error('OAuth token exchange failed', res.status);
    const txt = await res.text();
    console.error('OAuth body:', txt);
    return null;
  }
  const data = await res.json();
  return data.access_token;
}

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
};

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: CORS_HEADERS });
  }
  try {
    if (!PROJECT_ID) {
      return new Response(JSON.stringify({ error: 'FCM_PROJECT_ID not set' }), { status: 500, headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } });
    }

    const body = await req.json().catch(() => null);
    console.log('Request body:', body);
    const tripId = body?.tripId;
    const destination = body?.destination;
    const token = body?.token;

    if (!tripId || !destination || !token) {
      return new Response(
        JSON.stringify({ error: 'tripId, destination y token son requeridos', received: { tripId, destination, token } }),
        { status: 400, headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } }
      );
    }

    console.log('Received token preview:', typeof token === 'string' ? token.slice(0, 40) : token);
    console.log('Token length:', typeof token === 'string' ? token.length : 'na');
    if (typeof token !== 'string' || token.length < 20) {
      return new Response(JSON.stringify({ error: 'Token inválido o demasiado corto', tokenPreview: token?.slice?.(0, 40) ?? null }), { status: 400, headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } });
    }

    const accessToken = await getAccessToken();
  if (!accessToken) return new Response(JSON.stringify({ error: 'No se pudo obtener access_token' }), { status: 500, headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } });

  console.log('Calling FCM v1 API for project:', PROJECT_ID);
  const fcmRes = await fetch(`https://fcm.googleapis.com/v1/projects/${PROJECT_ID}/messages:send`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: {
          token,
          notification: { title: 'Nueva solicitud de viaje', body: `Destino: ${destination}` },
          data: { tripId: String(tripId) },
        },
      }),
    });

    const result = await fcmRes.json().catch(() => null);
    console.log('FCM status:', fcmRes.status, 'body:', result);

    if (!fcmRes.ok) {
      return new Response(JSON.stringify({ msg: 'Notificación no enviada', status: fcmRes.status, result }), { status: fcmRes.status, headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } });
    }

    return new Response(JSON.stringify({ msg: 'Notificación enviada ✅', result }), { status: 200, headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } });
  } catch (err) {
    console.error('Function error:', err);
    return new Response(JSON.stringify({ error: String(err) }), { status: 500, headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } });
  }
});
