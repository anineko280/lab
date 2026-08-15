import React, { useState, useEffect } from 'react';
import { BentoCard } from './BentoCard';
import { profileData } from '../data/profile';
import { 
  GithubIcon, 
  TwitterIcon, 
  MailIcon, 
  CopyIcon, 
  CheckIcon, 
  MapPinIcon, 
  ClockIcon, 
  SparklesIcon, 
  BookOpenIcon 
} from './Icons';
import './HeroCard.css';

export const HeroCard: React.FC = () => {
  const [currentTime, setCurrentTime] = useState<string>('');
  const [copied, setCopied] = useState(false);

  // Live JST Clock
  useEffect(() => {
    const updateTime = () => {
      const now = new Date();
      const options: Intl.DateTimeFormatOptions = {
        timeZone: 'Asia/Tokyo',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        hour12: false,
      };
      setCurrentTime(new Intl.DateTimeFormat('ja-JP', options).format(now));
    };

    updateTime();
    const interval = setInterval(updateTime, 1000);
    return () => clearInterval(interval);
  }, []);

  const handleCopyEmail = async (e: React.MouseEvent) => {
    e.preventDefault();
    const emailLink = profileData.socialLinks.find(s => s.icon === 'mail');
    const email = emailLink?.handle || 'hello@example.com';
    try {
      if (navigator?.clipboard?.writeText) {
        await navigator.clipboard.writeText(email);
      } else {
        const textarea = document.createElement('textarea');
        textarea.value = email;
        document.body.appendChild(textarea);
        textarea.select();
        document.execCommand('copy');
        document.body.removeChild(textarea);
      }
      setCopied(true);
      setTimeout(() => setCopied(false), 2500);
    } catch {
      window.location.href = `mailto:${email}`;
    }
  };

  return (
    <BentoCard colSpan={2} glowColor="cyan" className="hero-bento-card" id="hero">
      <div className="hero-inner">
        {/* Top bar: Status Pill & Live Time */}
        <div className="hero-topbar">
          <div className="status-pill">
            <span className="live-dot" />
            <span className="status-text">{profileData.status.label}</span>
          </div>

          <div className="time-location-pill">
            <span className="pill-item">
              <MapPinIcon size={14} className="pill-icon" />
              <span>{profileData.location}</span>
            </span>
            <span className="pill-divider">/</span>
            <span className="pill-item">
              <ClockIcon size={14} className="pill-icon" />
              <span className="time-mono">{currentTime || '12:00:00'} JST</span>
            </span>
          </div>
        </div>

        {/* Main Hero Content */}
        <div className="hero-main">
          {/* Avatar with Glow & Ring */}
          <div className="avatar-wrapper">
            <div className="avatar-glow" />
            <div className="avatar-frame">
              <img 
                src={profileData.avatar} 
                alt={profileData.name} 
                className="avatar-img"
              />
            </div>
            <div className="avatar-badge">
              <SparklesIcon size={14} />
            </div>
          </div>

          {/* Titles & Bio */}
          <div className="hero-text-content">
            <div className="hero-name-row">
              <h1 className="hero-name text-gradient">{profileData.name}</h1>
              <span className="role-tag">{profileData.role}</span>
            </div>
            
            <p className="hero-headline">{profileData.headline}</p>

            <div className="hero-bio-short">
              {profileData.bio.map((paragraph, idx) => (
                <p key={idx}>{paragraph}</p>
              ))}
            </div>
          </div>
        </div>

        {/* Quick Social & Action Links */}
        <div className="hero-actions">
          <div className="social-links-group">
            {profileData.socialLinks.map((social) => {
              if (social.icon === 'mail') {
                return (
                  <button
                    key={social.name}
                    className={`action-btn email-copy-btn ${copied ? 'copied' : ''}`}
                    onClick={handleCopyEmail}
                    title="メールアドレスをコピー"
                  >
                    {copied ? <CheckIcon size={18} /> : <CopyIcon size={18} />}
                    <span>{copied ? 'Copied!' : 'Copy Email'}</span>
                  </button>
                );
              }

              return (
                <a
                  key={social.name}
                  href={social.url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="action-btn social-link-btn"
                  aria-label={social.name}
                >
                  {social.icon === 'github' && <GithubIcon size={18} />}
                  {social.icon === 'twitter' && <TwitterIcon size={18} />}
                  {social.icon === 'zenn' && <BookOpenIcon size={18} />}
                  <span>{social.name}</span>
                </a>
              );
            })}
          </div>

          {/* Quick Monorepo Tag */}
          <div className="monorepo-tag">
            <span className="mono-code">lab/profile</span>
          </div>
        </div>
      </div>
    </BentoCard>
  );
};
