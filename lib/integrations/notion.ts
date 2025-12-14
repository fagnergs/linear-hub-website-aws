/**
 * Notion Integration Module
 * Logs contacts and deployments to Notion databases
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

/**
 * Add contact to Notion database
 * 
 * Function to call in your Notion:
 * ```javascript
 * import { addContactToNotion } from 'lib/integrations/notion';
 * 
 * await addContactToNotion(
 *   process.env.NOTION_API_KEY,
 *   process.env.NOTION_CONTACTS_DATABASE_ID,
 *   { name, email, company, subject, message }
 * );
 * ```
 * 
 * @param apiKey - Notion API key (environment variable)
 * @param databaseId - Notion contacts database ID
 * @param contact - Contact form data
 */
export async function addContactToNotion(
  apiKey: string,
  databaseId: string,
  contact: ContactData
): Promise<void> {
  if (!apiKey || !databaseId) {
    console.warn('Notion credentials not configured, skipping contact logging');
    return;
  }

  try {
    const response = await fetch('https://api.notion.com/v1/pages', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
        'Notion-Version': '2022-06-28',
      },
      body: JSON.stringify({
        parent: { database_id: databaseId },
        properties: {
          Name: {
            title: [{ text: { content: contact.name } }],
          },
          Email: {
            email: contact.email,
          },
          Company: {
            rich_text: [{ text: { content: contact.company || 'N/A' } }],
          },
          Subject: {
            rich_text: [{ text: { content: contact.subject } }],
          },
          Message: {
            rich_text: [{ text: { content: contact.message } }],
          },
          Created: {
            date: { start: new Date().toISOString() },
          },
          Status: {
            select: { name: 'new' },
          },
        },
      }),
    });

    if (!response.ok) {
      const error = await response.text();
      console.error('Notion API error:', error);
    } else {
      const data = await response.json();
      console.log('Contact added to Notion:', data.id);
    }
  } catch (error) {
    console.error('Error adding contact to Notion:', error);
    // Don't throw - Notion failure should not block main flow
  }
}

/**
 * Log deployment to Notion database
 * 
 * Function to call in your GitHub Actions:
 * ```javascript
 * import { logDeploymentToNotion } from 'lib/integrations/notion';
 * 
 * await logDeploymentToNotion(
 *   process.env.NOTION_API_KEY,
 *   process.env.NOTION_DEPLOYMENTS_DATABASE_ID,
 *   {
 *     branch: github.ref.split('/')[2],
 *     commit: github.sha.substring(0, 8),
 *     status: 'success',
 *     timestamp: new Date().toLocaleString('pt-BR'),
 *     duration: Date.now() - startTime
 *   }
 * );
 * ```
 * 
 * @param apiKey - Notion API key (environment variable)
 * @param databaseId - Notion deployments database ID
 * @param deployment - Deployment data
 */
export async function logDeploymentToNotion(
  apiKey: string,
  databaseId: string,
  deployment: DeploymentData
): Promise<void> {
  if (!apiKey || !databaseId) {
    console.warn('Notion credentials not configured, skipping deployment logging');
    return;
  }

  try {
    const response = await fetch('https://api.notion.com/v1/pages', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
        'Notion-Version': '2022-06-28',
      },
      body: JSON.stringify({
        parent: { database_id: databaseId },
        properties: {
          Branch: {
            title: [{ text: { content: deployment.branch } }],
          },
          Commit: {
            rich_text: [{ text: { content: deployment.commit } }],
          },
          Status: {
            select: { name: deployment.status === 'success' ? 'success' : 'failure' },
          },
          Timestamp: {
            date: { start: new Date().toISOString() },
          },
          Duration: deployment.duration
            ? { number: deployment.duration }
            : undefined,
        },
      }),
    });

    if (!response.ok) {
      const error = await response.text();
      console.error('Notion API error:', error);
    } else {
      const data = await response.json();
      console.log('Deployment logged to Notion:', data.id);
    }
  } catch (error) {
    console.error('Error logging deployment to Notion:', error);
    // Don't throw - Notion failure should not block main flow
  }
}
