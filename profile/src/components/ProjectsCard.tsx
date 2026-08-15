import React from 'react';
import { BentoCard } from './BentoCard';
import { profileData } from '../data/profile';
import { GithubIcon, ArrowUpRightIcon, CodeIcon } from './Icons';
import './ProjectsCard.css';

export const ProjectsCard: React.FC = () => {
  return (
    <BentoCard colSpan={2} glowColor="purple" className="projects-bento-card" id="projects">
      <div className="projects-inner">
        {/* Header */}
        <div className="projects-header">
          <div className="section-title-wrap">
            <span className="section-subtitle text-gradient-purple">Works & Prototypes</span>
            <h2 className="section-title">Featured Projects</h2>
          </div>
          <a
            href="https://github.com/anineko280?tab=repositories"
            target="_blank"
            rel="noopener noreferrer"
            className="view-all-link"
          >
            <span>View all on GitHub</span>
            <ArrowUpRightIcon size={16} />
          </a>
        </div>

        {/* Project List */}
        <div className="projects-grid">
          {profileData.featuredProjects.map((project) => (
            <div key={project.id} className="project-card-item">
              <div className="project-item-top">
                <div className="project-icon-badge">
                  <CodeIcon size={20} />
                </div>
                <div className="project-links">
                  {project.repoUrl && (
                    <a
                      href={project.repoUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="project-action-link"
                      title="GitHub Repository"
                    >
                      <GithubIcon size={16} />
                    </a>
                  )}
                  {project.demoUrl && project.demoUrl !== '#' && (
                    <a
                      href={project.demoUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="project-action-link"
                      title="Live Demo"
                    >
                      <ArrowUpRightIcon size={16} />
                    </a>
                  )}
                </div>
              </div>

              <div className="project-item-content">
                <h3 className="project-item-title">{project.title}</h3>
                <p className="project-item-desc">{project.description}</p>
              </div>

              <div className="project-item-tags">
                {project.tags.map((tag) => (
                  <span key={tag} className="tag-pill">
                    {tag}
                  </span>
                ))}
              </div>
            </div>
          ))}
        </div>
      </div>
    </BentoCard>
  );
};
