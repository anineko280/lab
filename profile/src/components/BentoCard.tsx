import React, { useRef, useState } from 'react';
import './BentoCard.css';

interface BentoCardProps {
  children: React.ReactNode;
  className?: string;
  colSpan?: 1 | 2 | 3 | 4;
  rowSpan?: 1 | 2;
  enableTilt?: boolean;
  glowColor?: 'indigo' | 'cyan' | 'purple' | 'emerald' | 'amber';
  id?: string;
}

export const BentoCard: React.FC<BentoCardProps> = ({
  children,
  className = '',
  colSpan = 1,
  rowSpan = 1,
  enableTilt = true,
  glowColor = 'indigo',
  id,
}) => {
  const cardRef = useRef<HTMLDivElement>(null);
  const [mousePos, setMousePos] = useState({ x: 0, y: 0 });
  const [tilt, setTilt] = useState({ rx: 0, ry: 0 });
  const [isHovered, setIsHovered] = useState(false);

  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    if (!cardRef.current) return;
    const rect = cardRef.current.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    setMousePos({ x, y });

    if (enableTilt) {
      const centerX = rect.width / 2;
      const centerY = rect.height / 2;
      const rx = ((y - centerY) / centerY) * -6; // max 6 deg
      const ry = ((x - centerX) / centerX) * 6;  // max 6 deg
      setTilt({ rx, ry });
    }
  };

  const handleMouseEnter = () => {
    setIsHovered(true);
  };

  const handleMouseLeave = () => {
    setIsHovered(false);
    setTilt({ rx: 0, ry: 0 });
  };

  return (
    <div
      ref={cardRef}
      id={id}
      className={`bento-card col-span-${colSpan} row-span-${rowSpan} glow-${glowColor} ${className}`}
      onMouseMove={handleMouseMove}
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
      style={{
        transform: isHovered && enableTilt
          ? `perspective(1000px) rotateX(${tilt.rx}deg) rotateY(${tilt.ry}deg) translateZ(4px)`
          : 'perspective(1000px) rotateX(0deg) rotateY(0deg) translateZ(0px)',
        // Pass mouse coordinates as CSS custom properties
        ['--mouse-x' as any]: `${mousePos.x}px`,
        ['--mouse-y' as any]: `${mousePos.y}px`,
      }}
    >
      {/* Spotlight cursor glow inside card */}
      <div className="bento-spotlight" />
      
      {/* Gradient border glow overlay */}
      <div className="bento-border" />

      {/* Card Content */}
      <div className="bento-content">
        {children}
      </div>
    </div>
  );
};
