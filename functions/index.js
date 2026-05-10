const functions = require("firebase-functions");
const admin = require("firebase-admin");
const https = require("https");

admin.initializeApp();

// 토스페이먼츠 빌링키로 결제 승인하는 Cloud Function
exports.approveBillingPayment = functions.https.onCall(async (data, context) => {
  // 로그인 확인
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "로그인이 필요합니다.");
  }

  const { billingKey, customerKey, amount, orderName, customerEmail, customerName } = data;

  if (!billingKey || !amount || !orderName) {
    throw new functions.https.HttpsError("invalid-argument", "필수 파라미터가 누락되었습니다.");
  }

  // 시크릿 키 (서버에서만 사용 - 절대 클라이언트에 노출 금지)
  const secretKey = functions.config().toss?.secret_key || "test_sk_zXLkKEypNArWmo50nX3lmeaxYG5R";
  const encodedKey = Buffer.from(secretKey + ":").toString("base64");

  const orderId = "order_" + Date.now() + "_" + Math.random().toString(36).substr(2, 9);

  const requestBody = JSON.stringify({
    customerKey,
    amount,
    orderId,
    orderName,
    customerEmail: customerEmail || "",
    customerName: customerName || "고객",
  });

  return new Promise((resolve, reject) => {
    const options = {
      hostname: "api.tosspayments.com",
      port: 443,
      path: `/v1/billing/${billingKey}`,
      method: "POST",
      headers: {
        Authorization: `Basic ${encodedKey}`,
        "Content-Type": "application/json",
        "Content-Length": Buffer.byteLength(requestBody),
      },
    };

    const req = https.request(options, (res) => {
      let responseData = "";
      res.on("data", (chunk) => { responseData += chunk; });
      res.on("end", () => {
        const parsed = JSON.parse(responseData);
        if (res.statusCode === 200) {
          resolve({ success: true, paymentKey: parsed.paymentKey, orderId: parsed.orderId });
        } else {
          reject(new functions.https.HttpsError("internal", parsed.message || "결제 실패"));
        }
      });
    });

    req.on("error", (e) => {
      reject(new functions.https.HttpsError("internal", e.message));
    });

    req.write(requestBody);
    req.end();
  });
});

// 빌링키 발급 승인 Cloud Function
exports.issueBillingKey = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "로그인이 필요합니다.");
  }

  const { authKey, customerKey } = data;

  if (!authKey || !customerKey) {
    throw new functions.https.HttpsError("invalid-argument", "authKey와 customerKey가 필요합니다.");
  }

  const secretKey = functions.config().toss?.secret_key || "test_sk_zXLkKEypNArWmo50nX3lmeaxYG5R";
  const encodedKey = Buffer.from(secretKey + ":").toString("base64");

  const requestBody = JSON.stringify({ authKey, customerKey });

  return new Promise((resolve, reject) => {
    const options = {
      hostname: "api.tosspayments.com",
      port: 443,
      path: "/v1/billing/authorizations/issue",
      method: "POST",
      headers: {
        Authorization: `Basic ${encodedKey}`,
        "Content-Type": "application/json",
        "Content-Length": Buffer.byteLength(requestBody),
      },
    };

    const req = https.request(options, (res) => {
      let responseData = "";
      res.on("data", (chunk) => { responseData += chunk; });
      res.on("end", () => {
        const parsed = JSON.parse(responseData);
        if (res.statusCode === 200) {
          resolve({ success: true, billingKey: parsed.billingKey, card: parsed.card });
        } else {
          reject(new functions.https.HttpsError("internal", parsed.message || "빌링키 발급 실패"));
        }
      });
    });

    req.on("error", (e) => {
      reject(new functions.https.HttpsError("internal", e.message));
    });

    req.write(requestBody);
    req.end();
  });
});
