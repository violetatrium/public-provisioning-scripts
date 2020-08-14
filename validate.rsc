{
  :global hasErrors false;
  :global hasWarnings false;
  :if ([:len [/interface bridge find name~"bridge"]] = 0) do={
    :log error "Main bridge must have 'bridge' (case-sensitive) in its name";
    :set hasErrors true;
  }

  :if ([/ip service get value-name=disabled ssh] != false) do={
    :log error "SSH service must be enabled";
    :set hasErrors true;
  }
  :if ([/ip service get value-name=port ssh] != 22) do={
    :log error "SSH service should have port set to 22, this will require an extra nat rule";
    :set hasErrors true;
  }
  :if ([/ip service get value-name=address ssh] != "") do={
    :log warn "SSH service has address set, ensure 10.0.4.0/22 is allowed";
    :set hasWarnings true;
  }

  :if ([/ip service get value-name=disabled api] != false) do={
    :log error "API service must be enabled";
    :set hasErrors true;
  }
  :if ([/ip service get value-name=port api] != 8728) do={
    :log error "API service should have port set to 8728, this will require an extra nat rule";
    :set hasErrors true;
  }
  :if ([/ip service get value-name=address api] != "") do={
    :log warn "API service has address set, ensure 10.0.4.0/22 is allowed";
    :set hasWarnings true;
  }

  :if ($hasErrors) do={
    :error "errors detected, please resolve the issues printed in the error log before provisioning";
  } else={
    :if ($hasWarnings) do={
      :put "One or more warning was encountered and can be seen in the warn log";
      :put "If provisioning fails check these warnings for hints at what might be wrong";
      :put "";
      :put "Configuration appears OK with warnings";
    } else={
      :put "All checks passed, configuration appears OK";
    }
  }
}

