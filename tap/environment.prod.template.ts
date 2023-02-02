export const environment = {
  production: true,
  baseHref: '/frontend/',
  authConfig: {
    requireHttps: true,
    issuer: 'https://$TAP_AUTH_SERVER_NAME-$TAP_DEV_NAMESPACE.$TAP_DEV_ENVIRONMENT.$TAP_MASTER_DOMAIN',
    clientId: 'dev_client-registration'
  },
  endpoints: {
    orders: window.location.origin + '/services/order-service/api/v1/orders',
    products: window.location.origin +  '/services/product-service/api/v1/products'
  }
};
