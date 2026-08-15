export interface SocialLink {
  name: string;
  url: string;
  icon: 'github' | 'twitter' | 'mail' | 'blog' | 'zenn' | 'qiita' | 'external';
  label: string;
  handle?: string;
}

export interface SkillCategory {
  title: string;
  icon: 'layout' | 'server' | 'terminal' | 'sparkles' | 'cpu';
  skills: {
    name: string;
    level?: 'expert' | 'proficient' | 'learning';
    highlight?: boolean;
  }[];
}

export interface ProjectItem {
  id: string;
  title: string;
  description: string;
  tags: string[];
  repoUrl?: string;
  demoUrl?: string;
  status: 'completed' | 'in-progress' | 'featured';
  featured?: boolean;
}

export interface TimelineItem {
  period: string;
  role: string;
  organization?: string;
  description: string;
  tags?: string[];
}

export interface ProfileData {
  name: string;
  role: string;
  avatar: string;
  location: string;
  status: {
    available: boolean;
    label: string;
  };
  headline: string;
  bio: string[];
  socialLinks: SocialLink[];
  skillCategories: SkillCategory[];
  featuredProjects: ProjectItem[];
  timeline: TimelineItem[];
  highlights: {
    label: string;
    value: string;
    description: string;
  }[];
}

export const profileData: ProfileData = {
  name: "anineko",
  role: "Software Engineer",
  avatar: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80",
  location: "Tokyo, Japan",
  status: {
    available: true,
    label: "Open to new projects & tech talks",
  },
  headline: "Crafting modern web experiences & building robust developer tools.",
  bio: [
    "Webフロントエンドからクラウド・自動化まで、モダンな開発体験と洗練されたプロダクトづくりを探求しています。",
    "個人開発や技術検証、開発環境の自動化（macOS / mise / dotfiles / Vite）に情熱を注いでいます。"
  ],
  socialLinks: [
    {
      name: "GitHub",
      url: "https://github.com/anineko280",
      icon: "github",
      label: "GitHub",
      handle: "@anineko280"
    },
    {
      name: "X (Twitter)",
      url: "https://twitter.com/",
      icon: "twitter",
      label: "X (Twitter)",
      handle: "@anineko"
    },
    {
      name: "Email",
      url: "mailto:hello@example.com",
      icon: "mail",
      label: "Email",
      handle: "hello@example.com"
    },
    {
      name: "Zenn / Qiita",
      url: "https://zenn.dev/",
      icon: "zenn",
      label: "Tech Blog",
      handle: "Articles"
    }
  ],
  highlights: [
    {
      label: "Focus",
      value: "Frontend & DX",
      description: "React, TypeScript & Modern Tooling"
    },
    {
      label: "Workflow",
      value: "Automation",
      description: "Monorepo, mise & Dotfiles"
    },
    {
      label: "Mindset",
      value: "Craftsmanship",
      description: "Clean UI & Performant Code"
    }
  ],
  skillCategories: [
    {
      title: "Frontend",
      icon: "layout",
      skills: [
        { name: "React", level: "expert", highlight: true },
        { name: "TypeScript", level: "expert", highlight: true },
        { name: "Vite", level: "proficient", highlight: true },
        { name: "Next.js", level: "proficient" },
        { name: "HTML5 / CSS3", level: "expert" },
        { name: "Vanilla CSS / Tailwind", level: "proficient" }
      ]
    },
    {
      title: "Backend & Systems",
      icon: "server",
      skills: [
        { name: "Node.js", level: "proficient", highlight: true },
        { name: "REST APIs", level: "proficient" },
        { name: "Python", level: "proficient" },
        { name: "Go (Exploring)", level: "learning" }
      ]
    },
    {
      title: "DevOps & Environment",
      icon: "terminal",
      skills: [
        { name: "Git / GitHub", level: "expert", highlight: true },
        { name: "mise", level: "proficient", highlight: true },
        { name: "Homebrew / Zsh", level: "proficient" },
        { name: "Docker", level: "proficient" }
      ]
    }
  ],
  featuredProjects: [
    {
      id: "lab-monorepo",
      title: "lab (Monorepo)",
      description: "個人の技術検証、Mac環境自動構築（setup.sh/dotfiles）、プロフィールサイトを一元管理するモノリポジトリ。",
      tags: ["Monorepo", "Zsh", "mise", "Vite", "React"],
      repoUrl: "https://github.com/anineko280/lab",
      status: "featured",
      featured: true
    },
    {
      id: "profile-site",
      title: "Profile & Portfolio Web",
      description: "ダークグラスモーフィズムとインタラクティブなBento Gridを採用した、高速で洗練されたプロフィールサイト。",
      tags: ["React", "TypeScript", "Vite", "Glassmorphism", "CSS Modules"],
      repoUrl: "https://github.com/anineko280/lab/tree/main/profile",
      demoUrl: "#",
      status: "featured",
      featured: true
    },
    {
      id: "mac-env-automation",
      title: "Mac Setup & Dotfiles",
      description: "Homebrew Bundle、Starship、mise を統合したMac初期環境の自動セットアップスクリプト群。",
      tags: ["Shell", "Homebrew", "dotfiles", "Starship"],
      repoUrl: "https://github.com/anineko280/lab/tree/main/setting",
      status: "completed"
    }
  ],
  timeline: [
    {
      period: "2026 - Present",
      role: "Software Engineering & Tech Exploration",
      organization: "Personal Lab",
      description: "フロントエンドから開発環境の自動化、モダンなWeb技術スタックの検証・実践を推進。",
      tags: ["React", "TypeScript", "DX", "Monorepo"]
    }
  ]
};
