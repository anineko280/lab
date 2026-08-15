import React from 'react';
import { BentoCard } from './BentoCard';
import { profileData } from '../data/profile';
import { SparklesIcon } from './Icons';
import './AboutCard.css';

export const AboutCard: React.FC = () => {
  return (
    <BentoCard colSpan={2} glowColor="emerald" className="about-bento-card" id="about">
      <div className="about-inner">
        <div className="about-header">
          <div className="section-title-wrap">
            <span className="section-subtitle text-gradient">Philosophy & Values</span>
            <h2 className="section-title">Approach & Focus</h2>
          </div>
        </div>

        {/* Highlights Row */}
        <div className="highlights-grid">
          {profileData.highlights.map((item, idx) => (
            <div key={idx} className="highlight-box">
              <span className="highlight-label">{item.label}</span>
              <span className="highlight-val">{item.value}</span>
              <span className="highlight-desc">{item.description}</span>
            </div>
          ))}
        </div>

        {/* Timeline / Current Focus */}
        <div className="current-focus-card">
          <div className="focus-indicator">
            <SparklesIcon size={18} className="focus-icon" />
            <span className="focus-title">Currently Building & Exploring</span>
          </div>
          <p className="focus-body">
            Mac環境の自動化（<code>setting/setup.sh</code>）と新技術スタック（<code>learning/</code>）を継続的に深掘り中。
            シンプルで堅牢な設計と、開発者体験（DX）を高めるツールチェーンに注力しています。
          </p>
        </div>
      </div>
    </BentoCard>
  );
};
