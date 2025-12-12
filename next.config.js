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
    NEXT_PUBLIC_API_ENDPOINT: process.env.NEXT_PUBLIC_API_ENDPOINT || '/api/contact',
    RESEND_API_KEY: process.env.RESEND_API_KEY,
  },
}

module.exports = nextConfig
