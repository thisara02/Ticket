// API Configuration for different environments
const getApiBaseUrl = () => {
  // Check if we're in development or production
  if (import.meta.env.DEV) {
    return 'http://localhost:5000';
  } else {
    // Production URL - update this with your actual domain
    return 'https://yourdomain.com'; // or http://yourdomain.com
  }
};

export const API_BASE_URL = getApiBaseUrl();

// API endpoints
export const API_ENDPOINTS = {
  // Customer endpoints
  CUSTOMER_LOGIN: `${API_BASE_URL}/api/customers/login`,
  CUSTOMER_PROFILE: `${API_BASE_URL}/api/customers/profile`,
  CUSTOMER_TICKETS: `${API_BASE_URL}/api/customers/tickets`,
  CUSTOMER_TICKET_COUNTS: `${API_BASE_URL}/api/customers/ticket-counts`,
  CUSTOMER_FORGOT_PASSWORD: `${API_BASE_URL}/api/customers/forgot-password/send-otp`,
  CUSTOMER_VERIFY_OTP: `${API_BASE_URL}/api/customers/forgot-password/verify-otp`,
  CUSTOMER_RESET_PASSWORD: `${API_BASE_URL}/api/customers/reset-password`,
  CUSTOMER_CHANGE_PASSWORD: `${API_BASE_URL}/api/customers/change-password`,
  CUSTOMER_TICKET_HISTORY: `${API_BASE_URL}/api/customers/ticket-history`,
  CUSTOMER_ONGOING_TICKETS: `${API_BASE_URL}/api/customers/ongoing-tickets`,
  CUSTOMER_PURCHASE_BUNDLE: `${API_BASE_URL}/api/customers/purchase-bundle`,
  
  // Ticket endpoints
  TICKET_USER_INFO: `${API_BASE_URL}/api/ticket/userinfo`,
  TICKET_FT: `${API_BASE_URL}/api/ticket/ft`,
  TICKET_SR: `${API_BASE_URL}/api/ticket/sr`,
  
  // File uploads
  UPLOADS: `${API_BASE_URL}/uploads`,
}; 