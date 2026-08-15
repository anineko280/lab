import React from 'react';
import { profileData } from '../data/profile';
import { GithubIcon, TwitterIcon, MailIcon, BookOpenIcon } from './Icons';
import './Footer.css';

export const Footer: React.FC = () => {
  return (
    <footer className="footer-container">
      <div className="footer-inner">
        <div className="footer-brand">
          <span className="footer-title">{profileData.name}</span>
          <span className="footer-subtitle">Personal Engineering Lab & Profile</span>
        </div>

        <div className="footer-links">
          {profileData.socialLinks.map((social) => (
            <a
              key={social.name}
              href={social.url}
              target="_blank"
              rel="noopener noreferrer"
              className="footer-social-link"
              aria-label={social.name}
            >
              {social.icon === 'github' && <GithubIcon size={18} />}
              {social.icon === 'twitter' && <TwitterIcon size={18} />}
              {social.icon === 'mail' && <MailIcon size={18} />}
              {social.icon === 'zenn' && <BookOpenIcon size={18} />}
            </a>
          ))}
        </div>

        <div className="footer-copy">
          <p>© {new Date().getFullYear()} {profileData.name}. All rights reserved.</p>
          <p className="footer-tech-stack">Built with Vite + React + TypeScript + Glassmorphism</p>
        </div>
      </div>
    </footer>
  );
};
