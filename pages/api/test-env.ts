import type { NextApiRequest, NextApiResponse } from 'next';

type ResponseData = {
  resendKeyExists: boolean;
  resendKeyLength?: number;
  resendKeyFirstChars?: string;
  allEnvKeys: string[];
};

export default function handler(
  req: NextApiRequest,
  res: NextApiResponse<ResponseData>
) {
  const RESEND_API_KEY = process.env.RESEND_API_KEY;
  const allKeys = Object.keys(process.env).filter(k => k.includes('RESEND') || k.includes('API') || k.includes('NEXT'));

  return res.status(200).json({
    resendKeyExists: !!RESEND_API_KEY,
    resendKeyLength: RESEND_API_KEY?.length,
    resendKeyFirstChars: RESEND_API_KEY ? `${RESEND_API_KEY.substring(0, 8)}...` : undefined,
    allEnvKeys: allKeys.slice(0, 20)
  });
}
