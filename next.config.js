/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',  // Generate static HTML/CSS/JS for S3 deployment
  trailingSlash: true,
  images: {
    unoptimized: true,
  },
  productionBrowserSourceMaps: false,
  
  // Public runtime configuration for API endpoint
  publicRuntimeConfig: {
    apiEndpoint: process.env.NEXT_PUBLIC_API_ENDPOINT || '/api/contact',
  },
  
  // Environment variables
  env: {
    NEXT_PUBLIC_API_ENDPOINT: process.env.NEXT_PUBLIC_API_ENDPOINT || 'https://xsp6ymu9u6.execute-api.us-east-1.amazonaws.com/prod/contact',
  },
}

module.exports = nextConfig
