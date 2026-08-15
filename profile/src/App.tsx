import React from 'react';
import { BackgroundEffect } from './components/BackgroundEffect';
import { Navbar } from './components/Navbar';
import { HeroCard } from './components/HeroCard';
import { AboutCard } from './components/AboutCard';
import { TechStackCard } from './components/TechStackCard';
import { ProjectsCard } from './components/ProjectsCard';
import { Footer } from './components/Footer';
import './App.css';

export const App: React.FC = () => {
  return (
    <div className="app-root">
      {/* Dynamic Aurora & Grid Ambient Background */}
      <BackgroundEffect />

      {/* Floating Navbar */}
      <Navbar />

      {/* Main Bento Grid Content */}
      <main className="container">
        <div className="bento-grid-layout">
          {/* Hero Section */}
          <HeroCard />

          {/* Philosophy / About Highlights */}
          <AboutCard />

          {/* Tech Stack & Skills */}
          <TechStackCard />

          {/* Projects / Works Showcase */}
          <ProjectsCard />
        </div>
      </main>

      {/* Footer */}
      <Footer />
    </div>
  );
};

export default App;
