export const environment = {
  production: true,
  baseHref: '/frontend/',
  authConfig: {
    requireHttps: true,
    issuer: 'https://authserver-1-dev.tap-next.blah.cloud',
    clientId: 'dev_client-registration'
  },
  endpoints: {
    orders: window.location.origin + '/services/order-service/api/v1/orders',
    products: window.location.origin +  '/services/product-service/api/v1/products'
  }
};
