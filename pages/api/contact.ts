import type { NextApiRequest, NextApiResponse } from 'next';

type ResponseData = {
  message: string;
  error?: string;
};

type ContactFormData = {
  name: string;
  email: string;
  company?: string;
  subject: string;
  message: string;
};

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse<ResponseData>
) {
  // Only allow POST requests
  if (req.method !== 'POST') {
    return res.status(405).json({ message: 'Method not allowed' });
  }

  try {
    const { name, email, company, subject, message }: ContactFormData = req.body;

    // Validate required fields
    if (!name || !email || !subject || !message) {
      return res.status(400).json({
        message: 'Todos os campos obrigatórios devem ser preenchidos',
        error: 'Missing required fields'
      });
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({
        message: 'Email inválido',
        error: 'Invalid email format'
      });
    }

    // Check if Resend API key is configured
    const RESEND_API_KEY = process.env.RESEND_API_KEY;

    if (!RESEND_API_KEY) {
      console.error('RESEND_API_KEY not configured - Check GitHub Secrets');
      console.log('Available env vars:', Object.keys(process.env).filter(k => k.includes('RESEND') || k.includes('API')));

      // For development/testing: log the form data
      console.log('Contact Form Submission (Email not sent - API key not configured):', {
        name,
        email,
        company,
        subject,
        message,
        timestamp: new Date().toISOString(),
      });

      return res.status(200).json({
        message: 'Mensagem recebida com sucesso! (Modo de desenvolvimento - email não enviado)'
      });
    }

    console.log('RESEND_API_KEY is configured, sending email...');

    // Send email using Resend
    const response = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${RESEND_API_KEY}`,
      },
      body: JSON.stringify({
        from: 'Linear Hub <noreply@linear-hub.com.br>',
        to: ['contato@linear-hub.com.br'],
        reply_to: email,
        subject: `[Website] ${subject}`,
        html: `
          <!DOCTYPE html>
          <html>
            <head>
              <meta charset="utf-8">
              <style>
                body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 8px 8px 0 0; }
                .content { background: #f9fafb; padding: 30px; border-radius: 0 0 8px 8px; }
                .field { margin-bottom: 20px; }
                .label { font-weight: bold; color: #667eea; margin-bottom: 5px; }
                .value { background: white; padding: 12px; border-radius: 4px; border-left: 3px solid #667eea; }
                .footer { margin-top: 30px; padding-top: 20px; border-top: 2px solid #e5e7eb; font-size: 12px; color: #6b7280; }
              </style>
            </head>
            <body>
              <div class="container">
                <div class="header">
                  <h2 style="margin: 0;">Nova Mensagem do Site - Linear Hub</h2>
                </div>
                <div class="content">
                  <div class="field">
                    <div class="label">Nome:</div>
                    <div class="value">${name}</div>
                  </div>

                  <div class="field">
                    <div class="label">Email:</div>
                    <div class="value"><a href="mailto:${email}">${email}</a></div>
                  </div>

                  ${company ? `
                  <div class="field">
                    <div class="label">Empresa:</div>
                    <div class="value">${company}</div>
                  </div>
                  ` : ''}

                  <div class="field">
                    <div class="label">Assunto:</div>
                    <div class="value">${subject}</div>
                  </div>

                  <div class="field">
                    <div class="label">Mensagem:</div>
                    <div class="value">${message.replace(/\n/g, '<br>')}</div>
                  </div>

                  <div class="footer">
                    <p>Esta mensagem foi enviada através do formulário de contato do site Linear Hub em ${new Date().toLocaleString('pt-BR')}.</p>
                  </div>
                </div>
              </div>
            </body>
          </html>
        `,
      }),
    });

    if (!response.ok) {
      const error = await response.text();
      console.error('Resend API error:', {
        status: response.status,
        statusText: response.statusText,
        error: error
      });
      
      // Parse error message if JSON
      let errorMessage = 'Failed to send email';
      try {
        const errorJson = JSON.parse(error);
        errorMessage = errorJson.message || error;
      } catch {
        errorMessage = error;
      }
      
      throw new Error(`Resend API Error (${response.status}): ${errorMessage}`);
    }

    const data = await response.json();
    console.log('Email sent successfully:', {
      id: data.id,
      from: data.from,
      to: data.to,
      created_at: data.created_at
    });

    return res.status(200).json({
      message: 'Mensagem enviada com sucesso! Entraremos em contato em breve.'
    });

  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : String(error);
    console.error('Contact API Error:', {
      message: errorMessage,
      stack: error instanceof Error ? error.stack : undefined,
      timestamp: new Date().toISOString()
    });
    
    return res.status(500).json({
      message: 'Erro ao enviar mensagem. Por favor, tente novamente mais tarde.',
      error: errorMessage
    });
  }
}
