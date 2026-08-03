import { ChevronDownIcon, KeyIcon } from "@heroicons/react/24/outline";
import { ReactNode, useState } from "react";
import { OnboardingLocalTab } from "../OnboardingCard/components/OnboardingLocalTab";
import { OnboardingProvidersTab } from "../OnboardingCard/components/OnboardingProvidersTab";
import OllamaLogo from "../svg/OllamaLogo";

interface ProviderSectionProps {
  title: string;
  icon: ReactNode;
  children: ReactNode;
}

function ProviderSection({ title, icon, children }: ProviderSectionProps) {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div className="border-border border-0 border-b border-solid">
      <button
        type="button"
        onClick={() => setIsOpen((prev) => !prev)}
        className="text-foreground flex w-full cursor-pointer items-center justify-between gap-2 border-none bg-transparent px-2 py-2.5 text-left text-sm font-medium hover:brightness-125"
      >
        <span className="flex items-center gap-2">
          {icon}
          {title}
        </span>
        <ChevronDownIcon
          className={`h-4 w-4 shrink-0 transition-transform duration-150 ${
            isOpen ? "rotate-180" : ""
          }`}
        />
      </button>
      {isOpen && <div className="px-1 pb-3">{children}</div>}
    </div>
  );
}

/**
 * Collapsible model provider setup shown in the History sidebar:
 * Local (Ollama) first, API keys (OpenAI/Anthropic) below it.
 */
export function ProviderQuickSetup() {
  return (
    <div className="mb-2">
      <ProviderSection
        title="Local (Ollama)"
        icon={<OllamaLogo width={16} height={16} />}
      >
        <OnboardingLocalTab />
      </ProviderSection>
      <ProviderSection title="API Keys" icon={<KeyIcon className="h-4 w-4" />}>
        <OnboardingProvidersTab providerIds={["openai", "anthropic"]} />
      </ProviderSection>
    </div>
  );
}
