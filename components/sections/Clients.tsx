import { useTranslation } from '@/lib/i18n';
import { motion } from 'framer-motion';
import { useInView } from 'react-intersection-observer';
import Image from 'next/image';

export default function Clients() {
  const { t } = useTranslation();
  const [ref, inView] = useInView({
    triggerOnce: true,
    threshold: 0.1,
  });

  const clients = [
    {
      name: 'Grupo Equatorial',
      logo: '/images/clients/equatorial.png',
      url: 'https://www.equatorialenergia.com.br/',
    },
    {
      name: 'Brasil Biofuels',
      logo: '/images/clients/brasilbiofuels.png',
      url: 'https://brasilbiofuels.com.br/',
    },
    {
      name: 'Energisa',
      logo: '/images/clients/energisa.png',
      url: 'https://www.energisa.com.br/',
    },
    {
      name: 'JHSF',
      logo: '/images/clients/jhsf.png',
      url: 'https://www.jhsf.com.br/',
    },
  ];

  return (
    <section id="clients" className="section-padding bg-gradient-to-br from-blue-50 to-cyan-50">
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
            {t('clients.title')}
          </span>
          <h2 className="text-responsive-lg font-display font-bold text-gray-900 mb-4">
            {t('clients.subtitle')}
          </h2>
        </motion.div>

        {/* Clients Grid */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-8 md:gap-12">
          {clients.map((client, index) => (
            <motion.a
              key={index}
              href={client.url}
              target="_blank"
              rel="noopener noreferrer"
              initial={{ opacity: 0, scale: 0.8 }}
              animate={inView ? { opacity: 1, scale: 1 } : {}}
              transition={{ duration: 0.5, delay: 0.1 + index * 0.1 }}
              className="group"
            >
              <div className="bg-white rounded-xl p-8 shadow-lg hover:shadow-2xl transition-all hover:-translate-y-2 flex items-center justify-center h-32">
                <div className="relative w-full h-20 grayscale group-hover:grayscale-0 transition-all duration-300">
                  <Image
                    src={client.logo}
                    alt={`${client.name} logo`}
                    fill
                    className="object-contain filter transition-all"
                    sizes="(max-width: 768px) 50vw, 25vw"
                  />
                </div>
              </div>
            </motion.a>
          ))}
        </div>

        {/* Trust Badge */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.6 }}
          className="mt-16 text-center"
        >
          <div className="inline-block bg-white rounded-2xl shadow-lg p-8 max-w-2xl">
            <p className="text-lg text-gray-700 leading-relaxed">
              <span className="font-bold text-primary-600">
                Organizações líderes
              </span>{' '}
              nos setores de energia, biocombustíveis e desenvolvimento imobiliário
              confiam em nossa expertise para suas iniciativas de transformação digital.
            </p>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
