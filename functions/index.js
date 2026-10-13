const { onCall } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const axios = require("axios");

// Initialize Firebase Admin SDK
admin.initializeApp();

// ==================== PAYPAL INTEGRATION ====================
const PAYPAL_CLIENT_ID = "BAAQosSwflX0RSMBwnVvcvh_NNqIivVZdAfYbrbLa85ezSZFIGj9_NC6zpfxLPvsfDR10zZwkNa98XM6y4";
const PAYPAL_SECRET = "ECeA4stJrdyO4A5nhNKYH21xQO60VJ8BBeHsaCI2td5bTXscPGKEqCnoThC_bbCLjiG7d8lCXmBcHHIR";
const PAYPAL_BASE = "https://api-m.sandbox.paypal.com";

// دالة الحصول على الـ Token من باي بال
async function getPayPalAccessToken() {
  const auth = Buffer.from(`${PAYPAL_CLIENT_ID}:${PAYPAL_SECRET}`).toString("base64");
  const response = await axios.post(`${PAYPAL_BASE}/v1/oauth/token`, "grant_type=client_credentials", {
    headers: {
      Authorization: `Basic ${auth}`,
      "Content-Type": "x-www-form-urlencoded",
    },
  });
  return response.data.access_token;
}

// استخدام onCall لتتوافق مع استدعاء Flutter
exports.createPayPalOrder = onCall(async (request) => {
  try {
    const amount = request.data.amount;
    const accessToken = await getPayPalAccessToken();

    const response = await axios.post(
      `${PAYPAL_BASE}/v2/checkout/orders`,
      {
        intent: "CAPTURE",
        purchase_units: [
          {
            amount: {
              currency_code: "USD",
              value: amount.toString(),
            },
          },
        ],
        application_context: {
          return_url: "https://example.com/return",
          cancel_url: "https://example.com/cancel",
        },
      },
      {
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
      }
    );

    const approvalUrl = response.data.links.find((link) => link.rel === "approve").href;

    return {
      success: true,
      approvalUrl: approvalUrl,
      orderId: response.data.id,
    };
  } catch (error) {
    console.error("PayPal Error:", error.response?.data || error.message);
    throw new Error(error.message);
  }
});

// ==================== NOTIFICATION FUNCTIONS ====================
const { sendNotifications } = require('./notifications/order_notifications');

exports.sendNotification = sendNotifications;