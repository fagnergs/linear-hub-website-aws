const RESEND_API_KEY = process.env.RESEND_API_KEY;
const RESEND_FROM = 'noreply@linear-hub.com.br';
const CONTACT_EMAIL = 'contato@linear-hub.com.br';

async function sendEmailViaResend(emailData) {
  try {
    const response = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${RESEND_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(emailData),
    });

    const responseData = await response.json();

    if (!response.ok) {
      throw new Error(`Resend API (${response.status}): ${JSON.stringify(responseData)}`);
    }

    return responseData;
  } catch (error) {
    throw error;
  }
}

function buildEmailHTML(name, email, company, subject, message) {
  return `
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 0; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; }
          .content { background: #f9fafb; padding: 30px; }
          .field { margin-bottom: 20px; background: white; padding: 15px; border-radius: 4px; border-left: 4px solid #667eea; }
          .label { font-weight: 700; color: #667eea; margin-bottom: 8px; font-size: 13px; }
          .value { color: #333; word-break: break-word; }
          .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #e5e7eb; font-size: 12px; color: #6b7280; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h2 style="margin: 0;">Mensagem do Formulário de Contato</h2>
          </div>
          <div class="content">
            <div class="field">
              <div class="label">NOME</div>
              <div class="value">${name}</div>
            </div>
            <div class="field">
              <div class="label">EMAIL</div>
              <div class="value">${email}</div>
            </div>
            ${company ? `<div class="field"><div class="label">EMPRESA</div><div class="value">${company}</div></div>` : ''}
            <div class="field">
              <div class="label">ASSUNTO</div>
              <div class="value">${subject}</div>
            </div>
            <div class="field">
              <div class="label">MENSAGEM</div>
              <div class="value">${message.replace(/\n/g, '<br>')}</div>
            </div>
            <div class="footer">
              <p>Enviado em ${new Date().toLocaleString('pt-BR')}</p>
            </div>
          </div>
        </div>
      </body>
    </html>
  `;
}

exports.handler = async (event) => {
  console.log('📧 Contact API called:', { method: event.httpMethod });

  // Handle CORS
  if (event.httpMethod === 'OPTIONS') {
    return {
      statusCode: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
      },
      body: '',
    };
  }

  if (event.httpMethod !== 'POST') {
    return {
      statusCode: 405,
      headers: { 'Access-Control-Allow-Origin': '*' },
      body: JSON.stringify({ message: 'Method not allowed' }),
    };
  }

  try {
    const body = JSON.parse(event.body || '{}');
    const { name, email, company, subject, message } = body;
    
    console.log('📝 Form data:', { name, email, subject: subject?.substring(0, 50) });

    // Validate
    if (!name || !email || !subject || !message) {
      return {
        statusCode: 400,
        headers: { 'Access-Control-Allow-Origin': '*' },
        body: JSON.stringify({
          message: 'Preencha todos os campos obrigatórios',
        })
      };
    }

    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      return {
        statusCode: 400,
        headers: { 'Access-Control-Allow-Origin': '*' },
        body: JSON.stringify({
          message: 'Email inválido',
        })
      };
    }

    if (!RESEND_API_KEY) {
      console.error('❌ RESEND_API_KEY not set');
      return {
        statusCode: 500,
        headers: { 'Access-Control-Allow-Origin': '*' },
        body: JSON.stringify({
          message: 'Erro: API não configurada',
        })
      };
    }

    console.log('📤 Sending via Resend...');

    const result = await sendEmailViaResend({
      from: RESEND_FROM,
      to: [CONTACT_EMAIL],
      reply_to: email,
      subject: `[Website] ${subject}`,
      html: buildEmailHTML(name, email, company, subject, message),
    });

    console.log('✅ Email sent:', result.id);

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        message: 'Mensagem enviada com sucesso! Entraremos em contato em breve.',
        id: result.id,
      })
    };

  } catch (error) {
    console.error('❌ Error:', error.message);
    
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        message: 'Erro ao enviar mensagem. Tente novamente.',
        error: error.message,
      })
    };
  }
};
