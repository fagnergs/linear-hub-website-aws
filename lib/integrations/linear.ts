/**
 * Linear Integration Module
 * Creates tasks and issues in Linear workspace
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
 * Create Linear task from contact submission
 * Auto-assigns to first team member with high priority
 * 
 * @param apiKey - Linear API key (environment variable)
 * @param title - Task title (from contact subject)
 * @param description - Task description (from contact message)
 * @param email - Contact email for reference
 * @returns Task ID
 */
export async function createLinearTask(
  apiKey: string,
  title: string,
  description: string,
  email: string
): Promise<string | null> {
  if (!apiKey) {
    console.warn('Linear API key not configured, skipping task creation');
    return null;
  }

  try {
    // GraphQL query to create issue
    const query = `
      mutation {
        issueCreate(
          input: {
            teamId: "team-1"
            title: "${escapeGraphQL(title)}"
            description: "${escapeGraphQL(description)}\n\nContato: ${email}"
            priority: 3
            assigneeId: null
          }
        ) {
          success
          issue {
            id
            identifier
            url
          }
        }
      }
    `;

    const response = await fetch('https://api.linear.app/graphql', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: JSON.stringify({ query }),
    });

    if (!response.ok) {
      const error = await response.text();
      console.error('Linear API error:', error);
      return null;
    }

    const data = await response.json();

    if (data.errors) {
      console.error('Linear GraphQL error:', data.errors);
      return null;
    }

    if (data.data?.issueCreate?.success) {
      const taskId = data.data.issueCreate.issue.id;
      console.log('Linear task created:', taskId);
      return taskId;
    }

    return null;
  } catch (error) {
    console.error('Error creating Linear task:', error);
    // Don't throw - Linear failure should not block main flow
    return null;
  }
}

/**
 * Create Linear issue for deployment failure
 * High priority, includes deployment details
 * 
 * @param apiKey - Linear API key (environment variable)
 * @param deployment - Deployment data
 * @returns Issue ID
 */
export async function createLinearIssue(
  apiKey: string,
  deployment: DeploymentData
): Promise<string | null> {
  if (!apiKey || deployment.status === 'success') {
    return null;
  }

  try {
    // Only create issue on failure
    if (deployment.status !== 'failure') {
      return null;
    }

    const title = `🚨 Deploy Failed: ${deployment.branch}`;
    const description = `
Deployment falhou no branch **${deployment.branch}**

- Commit: ${deployment.commit}
- Timestamp: ${deployment.timestamp}
- Duration: ${deployment.duration || 'N/A'}s

**Ação necessária:** Verificar logs de deploy e corrigir problema.
    `.trim();

    const query = `
      mutation {
        issueCreate(
          input: {
            teamId: "team-1"
            title: "${escapeGraphQL(title)}"
            description: "${escapeGraphQL(description)}"
            priority: 4
            labelIds: ["label-urgent"]
          }
        ) {
          success
          issue {
            id
            identifier
            url
          }
        }
      }
    `;

    const response = await fetch('https://api.linear.app/graphql', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: JSON.stringify({ query }),
    });

    if (!response.ok) {
      const error = await response.text();
      console.error('Linear API error:', error);
      return null;
    }

    const data = await response.json();

    if (data.errors) {
      console.error('Linear GraphQL error:', data.errors);
      return null;
    }

    if (data.data?.issueCreate?.success) {
      const issueId = data.data.issueCreate.issue.id;
      console.log('Linear issue created:', issueId);
      return issueId;
    }

    return null;
  } catch (error) {
    console.error('Error creating Linear issue:', error);
    // Don't throw - Linear failure should not block main flow
    return null;
  }
}

/**
 * Escape special characters for GraphQL queries
 * @param str - String to escape
 * @returns Escaped string
 */
function escapeGraphQL(str: string): string {
  return str
    .replace(/\\/g, '\\\\')
    .replace(/"/g, '\\"')
    .replace(/\n/g, '\\n')
    .replace(/\r/g, '\\r')
    .replace(/\t/g, '\\t');
}
