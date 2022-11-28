export const environment = {
  production: true,
  baseHref: '/frontend/',
  authConfig: {
    requireHttps: 'false',
    issuer: 'http://authserver-1-dev.tap.blah.cloud',
    clientId: 'dev-space_client-registration'
  },
  endpoints: {
    orders: window.location.origin + '/services/order-service/api/v1/orders',
    products: window.location.origin +  '/services/product-service/api/v1/products'
  }
};
