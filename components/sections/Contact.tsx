import { useState } from 'react';
import { useTranslation } from '@/lib/i18n';
import { motion } from 'framer-motion';
import { useInView } from 'react-intersection-observer';
import { Mail, Phone, MapPin, Send, Linkedin, CheckCircle, AlertCircle, Loader2 } from 'lucide-react';

export default function Contact() {
  const { t } = useTranslation();
  const [ref, inView] = useInView({
    triggerOnce: true,
    threshold: 0.1,
  });

  const [formData, setFormData] = useState({
    name: '',
    email: '',
    subject: '',
    message: '',
  });

  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitStatus, setSubmitStatus] = useState<'idle' | 'success' | 'error'>('idle');
  const [errorMessage, setErrorMessage] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    setSubmitStatus('idle');
    setErrorMessage('');

    try {
      if (!formData.name || !formData.email || !formData.subject || !formData.message) {
        setSubmitStatus('error');
        setErrorMessage('Preencha todos os campos');
        setIsSubmitting(false);
        return;
      }

      const apiUrl = 'https://xsp6ymu9u6.execute-api.us-east-1.amazonaws.com/prod/contact';
      
      console.log('Iniciando envio para:', apiUrl);

      const response = await fetch(apiUrl, {
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData),
      });

      console.log('Resposta status:', response.status);

      if (response.ok) {
        const data = await response.json();
        console.log('Sucesso:', data);
        setSubmitStatus('success');
        setFormData({ name: '', email: '', subject: '', message: '' });
        setTimeout(() => setSubmitStatus('idle'), 5000);
      } else {
        try {
          const data = await response.json();
          console.error('Erro de resposta:', data);
          setSubmitStatus('error');
          setErrorMessage(data.message || `Erro: ${response.status}`);
        } catch (parseError) {
          console.error('Erro ao parsear resposta:', parseError);
          setSubmitStatus('error');
          setErrorMessage(`Erro ao enviar (HTTP ${response.status})`);
        }
      }
    } catch (error) {
      console.error('Erro na requisição:', error);
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error('Detalhes:', errorMsg);
      setSubmitStatus('error');
      setErrorMessage('Falha na conexão. Verifique sua internet e tente novamente.');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  return (
    <section id="contact" className="section-padding bg-gradient-to-br from-gray-50 to-white">
      <div className="container-custom">
        {/* Section Header */}
        <motion.div
          ref={ref}
          initial={{ opacity: 0, y: 20 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <span className="inline-block px-4 py-2 bg-primary-100 text-primary-700 rounded-full text-sm font-semibold mb-4">
            {t('contact.title')}
          </span>
          <h2 className="text-responsive-lg font-display font-bold text-gray-900 mb-4">
            {t('contact.subtitle')}
          </h2>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.2 }}
          className="max-w-2xl mx-auto"
        >
          <form onSubmit={handleSubmit} className="bg-white rounded-2xl shadow-xl p-8 space-y-5">
            <div className="grid md:grid-cols-2 gap-4">
              <input
                type="text"
                name="name"
                placeholder="Seu nome *"
                value={formData.name}
                onChange={handleChange}
                required
                className="px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
              />
              <input
                type="email"
                name="email"
                placeholder="Seu email *"
                value={formData.email}
                onChange={handleChange}
                required
                className="px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
              />
            </div>

            <input
              type="text"
              name="subject"
              placeholder="Assunto *"
              value={formData.subject}
              onChange={handleChange}
              required
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
            />

            <textarea
              name="message"
              placeholder="Sua mensagem *"
              value={formData.message}
              onChange={handleChange}
              required
              rows={5}
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent resize-none"
            />

            {submitStatus === 'success' && (
              <motion.div
                initial={{ opacity: 0, y: -10 }}
                animate={{ opacity: 1, y: 0 }}
                className="p-4 bg-green-50 border border-green-200 rounded-lg text-green-800 flex items-center gap-2"
              >
                <CheckCircle className="w-5 h-5" />
                <span>Mensagem enviada com sucesso!</span>
              </motion.div>
            )}

            {submitStatus === 'error' && (
              <motion.div
                initial={{ opacity: 0, y: -10 }}
                animate={{ opacity: 1, y: 0 }}
                className="p-4 bg-red-50 border border-red-200 rounded-lg text-red-800 flex items-center gap-2"
              >
                <AlertCircle className="w-5 h-5" />
                <span>{errorMessage}</span>
              </motion.div>
            )}

            <button
              type="submit"
              disabled={isSubmitting}
              className="w-full btn-primary flex items-center justify-center gap-2"
            >
              {isSubmitting ? (
                <>
                  <Loader2 className="w-5 h-5 animate-spin" />
                  Enviando...
                </>
              ) : (
                <>
                  Enviar
                  <Send className="w-5 h-5" />
                </>
              )}
            </button>
          </form>

          <div className="grid md:grid-cols-3 gap-6 mt-12">
            <a href="https://maps.google.com/?q=Jaguariúna,SP" target="_blank" rel="noopener noreferrer" className="text-center p-6 bg-white rounded-xl shadow-md hover:shadow-lg transition">
              <MapPin className="w-8 h-8 text-primary-600 mx-auto mb-3" />
              <p className="font-semibold text-gray-900">{t('contact.info.location')}</p>
            </a>
            <a href="tel:+5521992544456" className="text-center p-6 bg-white rounded-xl shadow-md hover:shadow-lg transition">
              <Phone className="w-8 h-8 text-primary-600 mx-auto mb-3" />
              <p className="font-semibold text-gray-900">{t('contact.info.phone')}</p>
            </a>
            <a href="mailto:contato@linear-hub.com.br" className="text-center p-6 bg-white rounded-xl shadow-md hover:shadow-lg transition">
              <Mail className="w-8 h-8 text-primary-600 mx-auto mb-3" />
              <p className="font-semibold text-gray-900">{t('contact.info.email')}</p>
            </a>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
