import React, { useState } from 'react';
import { BentoCard } from './BentoCard';
import { profileData } from '../data/profile';
import { LayoutIcon, ServerIcon, TerminalIcon, SparklesIcon } from './Icons';
import './TechStackCard.css';

export const TechStackCard: React.FC = () => {
  const [activeTab, setActiveTab] = useState<number>(0);

  const getCategoryIcon = (icon: string) => {
    switch (icon) {
      case 'layout': return <LayoutIcon size={18} />;
      case 'server': return <ServerIcon size={18} />;
      case 'terminal': return <TerminalIcon size={18} />;
      default: return <SparklesIcon size={18} />;
    }
  };

  const currentCategory = profileData.skillCategories[activeTab];

  return (
    <BentoCard colSpan={2} glowColor="indigo" className="tech-stack-bento-card" id="skills">
      <div className="tech-stack-inner">
        {/* Header */}
        <div className="tech-header">
          <div className="section-title-wrap">
            <span className="section-subtitle text-gradient">Expertise & Tools</span>
            <h2 className="section-title">Tech Stack & Skills</h2>
          </div>

          {/* Category Tabs */}
          <div className="category-tabs" role="tablist">
            {profileData.skillCategories.map((category, idx) => (
              <button
                key={category.title}
                role="tab"
                aria-selected={activeTab === idx}
                className={`tab-btn ${activeTab === idx ? 'active' : ''}`}
                onClick={() => setActiveTab(idx)}
              >
                {getCategoryIcon(category.icon)}
                <span>{category.title}</span>
              </button>
            ))}
          </div>
        </div>

        {/* Skills Grid */}
        <div className="skills-grid-container">
          <div className="skills-pill-grid">
            {currentCategory.skills.map((skill) => (
              <div 
                key={skill.name} 
                className={`skill-badge ${skill.highlight ? 'highlight' : ''}`}
              >
                {skill.highlight && <span className="skill-glow-dot" />}
                <span className="skill-name">{skill.name}</span>
                {skill.level && (
                  <span className={`skill-level-tag level-${skill.level}`}>
                    {skill.level === 'expert' ? 'Core' : skill.level === 'proficient' ? 'Proficient' : 'Learning'}
                  </span>
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Footer info note */}
        <div className="tech-footer-note">
          <span className="note-icon">✨</span>
          <span className="note-text">
            実務および検証プロジェクト（<code>lab/learning</code>）で継続的にアップデート中
          </span>
        </div>
      </div>
    </BentoCard>
  );
};
