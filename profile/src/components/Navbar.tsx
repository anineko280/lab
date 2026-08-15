import React, { useState, useEffect } from 'react';
import { GithubIcon, SparklesIcon } from './Icons';
import './Navbar.css';

export const Navbar: React.FC = () => {
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 20);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <header className={`navbar-header ${scrolled ? 'scrolled' : ''}`}>
      <div className="navbar-container">
        {/* Brand / Logo */}
        <a href="#hero" className="navbar-brand">
          <div className="brand-icon">
            <SparklesIcon size={16} />
          </div>
          <span className="brand-title">anineko<span className="brand-dot">.dev</span></span>
        </a>

        {/* Navigation Links */}
        <nav className="navbar-nav">
          <a href="#hero" className="nav-link">Home</a>
          <a href="#skills" className="nav-link">Skills</a>
          <a href="#projects" className="nav-link">Projects</a>
          <a href="#about" className="nav-link">About</a>
        </nav>

        {/* Action Button */}
        <div className="navbar-action">
          <a
            href="https://github.com/anineko280/lab"
            target="_blank"
            rel="noopener noreferrer"
            className="navbar-github-btn"
          >
            <GithubIcon size={18} />
            <span className="github-btn-text">lab repo</span>
          </a>
        </div>
      </div>
    </header>
  );
};
