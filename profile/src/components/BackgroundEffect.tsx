import React from 'react';
import './BackgroundEffect.css';

export const BackgroundEffect: React.FC = () => {
  return (
    <div className="bg-effects-container" aria-hidden="true">
      {/* Aurora glow blobs */}
      <div className="glow-blob glow-blob-1" />
      <div className="glow-blob glow-blob-2" />
      <div className="glow-blob glow-blob-3" />
      
      {/* Fine grid pattern overlay */}
      <div className="grid-overlay" />

      {/* Radial vignette */}
      <div className="vignette-overlay" />
    </div>
  );
};
