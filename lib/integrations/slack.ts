/**
 * Slack Integration Module
 * Sends notifications to Slack for contacts and deployments
 */

interface ContactData {
  name: string;
  email: string;
  company?: string;
  subject: string;
  message: string;
}

interface DeploymentData {
  branch: string;
  commit: string;
  status: 'success' | 'failure';
  timestamp: string;
  duration?: number;
}

interface SlackMessagePayload {
  channel: string;
  blocks: Array<{
    type: string;
    text?: { type: string; text: string; emoji?: boolean };
    fields?: Array<{ type: string; text: string }>;
  }>;
}

/**
 * Send message to Slack via webhook
 * @param webhookUrl - Slack webhook URL from environment
 * @param channel - Channel name (e.g., '#contacts')
 * @param payload - Slack message payload (blocks format)
 */
export async function sendSlackMessage(
  webhookUrl: string,
  channel: string,
  payload: SlackMessagePayload
): Promise<void> {
  if (!webhookUrl) {
    console.warn('Slack webhook URL not configured, skipping notification');
    return;
  }

  try {
    const response = await fetch(webhookUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      console.error('Slack API error:', response.statusText);
    } else {
      console.log(`Slack notification sent to ${channel}`);
    }
  } catch (error) {
    console.error('Error sending Slack message:', error);
    // Don't throw - Slack failure should not block main flow
  }
}

/**
 * Format contact submission notification for Slack
 * @param contact - Contact form data
 * @returns Slack message payload
 */
export function formatContactNotification(contact: ContactData): SlackMessagePayload {
  return {
    channel: '#contacts',
    blocks: [
      {
        type: 'header',
        text: {
          type: 'plain_text',
          text: '📬 Novo Contato - Website Linear Hub',
          emoji: true,
        },
      },
      {
        type: 'section',
        fields: [
          {
            type: 'mrkdwn',
            text: `*Nome:*\n${contact.name}`,
          },
          {
            type: 'mrkdwn',
            text: `*Email:*\n<mailto:${contact.email}|${contact.email}>`,
          },
          {
            type: 'mrkdwn',
            text: `*Assunto:*\n${contact.subject}`,
          },
          {
            type: 'mrkdwn',
            text: `*Empresa:*\n${contact.company || 'Não informado'}`,
          },
        ],
      },
      {
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: `*Mensagem:*\n${contact.message.substring(0, 500)}${contact.message.length > 500 ? '...' : ''}`,
        },
      },
      {
        type: 'divider',
      },
      {
        type: 'context',
        elements: [
          {
            type: 'mrkdwn',
            text: `_Recebido em: ${new Date().toLocaleString('pt-BR')}_`,
          },
        ],
      },
    ],
  };
}

/**
 * Format deployment status notification for Slack
 * @param deployment - Deployment data
 * @returns Slack message payload
 */
export function formatDeploymentNotification(deployment: DeploymentData): SlackMessagePayload {
  const isSuccess = deployment.status === 'success';
  const emoji = isSuccess ? '✅' : '❌';
  const statusText = isSuccess ? 'Bem-sucedido' : 'Falhou';
  const color = isSuccess ? '#36a64f' : '#e74c3c';

  return {
    channel: '#deployments',
    blocks: [
      {
        type: 'header',
        text: {
          type: 'plain_text',
          text: `${emoji} Deploy ${statusText}`,
          emoji: true,
        },
      },
      {
        type: 'section',
        fields: [
          {
            type: 'mrkdwn',
            text: `*Branch:*\n${deployment.branch}`,
          },
          {
            type: 'mrkdwn',
            text: `*Commit:*\n\`${deployment.commit.substring(0, 8)}\``,
          },
          {
            type: 'mrkdwn',
            text: `*Status:*\n${statusText}`,
          },
          {
            type: 'mrkdwn',
            text: `*Duração:*\n${deployment.duration ? `${deployment.duration}s` : 'N/A'}`,
          },
        ],
      },
      {
        type: 'divider',
      },
      {
        type: 'context',
        elements: [
          {
            type: 'mrkdwn',
            text: `_${deployment.timestamp}_`,
          },
        ],
      },
    ],
  };
}
