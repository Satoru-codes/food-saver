import "./style.css";
import { isSupabaseConfigured, supabase } from "./lib/supabase.js";
import { mountPantry } from "./pantry.js";

const $ = (selector) => document.querySelector(selector);

const text = {
  en: {
    eyebrow: "A smarter way to manage food at home",
    headline: "A little more mindful.<br />A lot less waste.",
    intro: "Keep your household pantry organised, understand what gets used, and make less food go to waste.",
    point1: "One shared household pantry",
    point2: "Track consumption and food waste",
    point3: "English and Hindi",
    signinTab: "Sign in",
    signupTab: "Create account",
    welcomeBack: "Welcome back",
    signinIntro: "Sign in to continue to your household pantry.",
    emailLabel: "Email address",
    passwordLabel: "Password",
    signinButton: "Sign in",
    forgotPassword: "Forgot your password?",
    createAccountTitle: "Create your account",
    signupIntro: "Start by creating your personal FoodSaver account.",
    nameLabel: "Your name",
    createAccountButton: "Create account",
    emailConfirmNote: "We'll send a confirmation link to your email address.",
    resetTitle: "Reset your password",
    resetIntro: "Enter your email and we'll send you a password reset link.",
    sendResetLink: "Send reset link",
    backToSignIn: "Back to sign in",
    newPasswordTitle: "Choose a new password",
    newPasswordLabel: "New password",
    updatePassword: "Update password",
    signedIn: "You're signed in",
    householdTitle: "Create your household",
    householdIntro: "Give your shared pantry a name. You can invite family members after setup.",
    householdNameLabel: "Household name",
    createHousehold: "Create household",
    signOut: "Sign out",
    workspaceReady: "Account connected",
    setupConnectedTitle: "Authentication and household setup are connected.",
    setupConnectedBody: "The next development step is connecting pantry items to the shared database. Your existing browser-only pantry has not been imported.",
    footer: "FoodSaver · Less waste, more thoughtful kitchens.",
    checking: "Checking connection…",
    connected: "Supabase connection configured",
    missingConfig: "Supabase configuration missing",
    roleOwner: "You are the household Owner.",
    roleAdmin: "You are an Admin in this household.",
    roleMember: "You are a Member in this household.",
    checkEmail: "Account created. Check your inbox and confirm your email before signing in.",
    signupSuccess: "Your account is ready.",
    resetSent: "If an account exists for this email, a password reset link has been sent.",
    passwordUpdated: "Password updated. You can now continue.",
    householdCreated: "Household created successfully.",
    signedOut: "You have signed out.",
    genericError: "Something went wrong. Please try again.",
    noHouseholds: "No household is linked to this account yet.",
    selectHousehold: "Your households"
  },
  hi: {
    eyebrow: "घर में खाने-पीने का सामान बेहतर तरीके से संभालें",
    headline: "समझदारी से इस्तेमाल।<br />खाने की कम बर्बादी।",
    intro: "घर के खाने-पीने के सामान को व्यवस्थित रखें, इस्तेमाल पर नज़र रखें और खाने की बर्बादी कम करें।",
    point1: "परिवार के लिए एक साझा पैंट्री",
    point2: "इस्तेमाल और खाने की बर्बादी का रिकॉर्ड",
    point3: "अंग्रेज़ी और हिन्दी",
    signinTab: "साइन इन",
    signupTab: "खाता बनाएँ",
    welcomeBack: "वापस स्वागत है",
    signinIntro: "अपनी घरेलू पैंट्री में जाने के लिए साइन इन करें।",
    emailLabel: "ईमेल पता",
    passwordLabel: "पासवर्ड",
    signinButton: "साइन इन",
    forgotPassword: "पासवर्ड भूल गए?",
    createAccountTitle: "अपना खाता बनाएँ",
    signupIntro: "अपना FoodSaver खाता बनाकर शुरुआत करें।",
    nameLabel: "आपका नाम",
    createAccountButton: "खाता बनाएँ",
    emailConfirmNote: "हम आपके ईमेल पते पर पुष्टि लिंक भेजेंगे।",
    resetTitle: "पासवर्ड रीसेट करें",
    resetIntro: "अपना ईमेल दर्ज करें। हम पासवर्ड रीसेट लिंक भेजेंगे।",
    sendResetLink: "रीसेट लिंक भेजें",
    backToSignIn: "साइन इन पर वापस जाएँ",
    newPasswordTitle: "नया पासवर्ड चुनें",
    newPasswordLabel: "नया पासवर्ड",
    updatePassword: "पासवर्ड अपडेट करें",
    signedIn: "आप साइन इन हैं",
    householdTitle: "अपना परिवार जोड़ें",
    householdIntro: "अपनी साझा पैंट्री को एक नाम दें। बाद में परिवार के सदस्यों को आमंत्रित कर सकते हैं।",
    householdNameLabel: "परिवार का नाम",
    createHousehold: "परिवार बनाएँ",
    signOut: "साइन आउट",
    workspaceReady: "खाता जुड़ गया",
    setupConnectedTitle: "खाता और परिवार सेटअप जुड़ चुके हैं।",
    setupConnectedBody: "अगला चरण पैंट्री के सामान को साझा डेटाबेस से जोड़ना है। पुराने ब्राउज़र वाले सामान को अभी आयात नहीं किया गया है।",
    footer: "FoodSaver · कम बर्बादी, बेहतर रसोई।",
    checking: "कनेक्शन जाँचा जा रहा है…",
    connected: "Supabase कनेक्शन सेट है",
    missingConfig: "Supabase कॉन्फ़िगरेशन उपलब्ध नहीं है",
    roleOwner: "आप इस परिवार के Owner हैं।",
    roleAdmin: "आप इस परिवार के Admin हैं।",
    roleMember: "आप इस परिवार के Member हैं।",
    checkEmail: "खाता बन गया है। ईमेल खोलें और साइन इन करने से पहले पते की पुष्टि करें।",
    signupSuccess: "आपका खाता तैयार है।",
    resetSent: "यदि इस ईमेल से खाता मौजूद है, तो रीसेट लिंक भेज दिया गया है।",
    passwordUpdated: "पासवर्ड अपडेट हो गया है। अब आगे बढ़ सकते हैं।",
    householdCreated: "परिवार सफलतापूर्वक बन गया।",
    signedOut: "आप साइन आउट हो गए हैं।",
    genericError: "कुछ गड़बड़ हुई। कृपया फिर कोशिश करें।",
    noHouseholds: "इस खाते से अभी कोई परिवार जुड़ा नहीं है।",
    selectHousehold: "आपके परिवार"
  }
};

let language = localStorage.getItem("foodsaver_language") || "en";
let currentUser = null;
let isSubmitting = false;
let pantryController = null;
let activeHouseholdId = null;

function t(key) {
  return text[language]?.[key] ?? text.en[key] ?? key;
}

function applyLanguage() {
  document.documentElement.lang = language;
  $("#language-select").value = language;
  document.querySelectorAll("[data-i18n]").forEach((node) => {
    const key = node.dataset.i18n;
    if (key === "headline") node.innerHTML = t(key);
    else node.textContent = t(key);
  });
}

function showStatus(message, type = "info") {
  const node = $("#status-message");
  node.textContent = message;
  node.className = `status-message ${type}`;
  node.hidden = false;
}

function showHouseholdStatus(message, type = "info") {
  const node = $("#household-status-message");
  node.textContent = message;
  node.className = `status-message ${type}`;
  node.hidden = false;
}

function clearStatus() {
  const node = $("#status-message");
  node.textContent = "";
  node.hidden = true;
  node.className = "status-message";
}

function setBusy(form, busy) {
  form.querySelectorAll("button").forEach((button) => {
    button.disabled = busy;
  });
}

function showAuthPanel(panel) {
  if (pantryController) {
    pantryController.destroy();
    pantryController = null;
    activeHouseholdId = null;
  }
  $("#auth-hero").hidden = false;
  $("#workspace-view").hidden = true;
  $("#auth-card").hidden = false;
  $("#household-card").hidden = true;
  $("#workspace-card").hidden = true;
  $("#signin-panel").hidden = panel !== "signin";
  $("#signup-panel").hidden = panel !== "signup";
  $("#reset-panel").hidden = panel !== "reset";
  $("#new-password-panel").hidden = panel !== "new-password";
  $("#tab-signin").classList.toggle("active", panel === "signin");
  $("#tab-signup").classList.toggle("active", panel === "signup");
  $("#tab-signin").setAttribute("aria-selected", String(panel === "signin"));
  $("#tab-signup").setAttribute("aria-selected", String(panel === "signup"));
  clearStatus();
}

function friendlyError(error) {
  const message = String(error?.message || "");
  if (/invalid login credentials/i.test(message)) return "Email or password is incorrect.";
  if (/user already registered/i.test(message)) return "An account with this email already exists. Sign in instead.";
  if (/password should be at least/i.test(message)) return "Choose a password with at least 8 characters.";
  if (/email not confirmed/i.test(message)) return "Please confirm your email address before signing in.";
  if (/rate limit/i.test(message)) return "Too many attempts. Please wait a little and try again.";
  if (/failed to fetch|network/i.test(message)) return "Could not reach Supabase. Check your connection and project settings.";
  return message || t("genericError");
}

async function loadHouseholds() {
  const { data: memberships, error: memberError } = await supabase
    .from("household_members")
    .select("household_id, role, can_manage_inventory, can_log_own_consumption, can_log_others_consumption, can_record_waste, can_view_household_analytics, can_manage_members")
    .eq("user_id", currentUser.id);

  if (memberError) throw memberError;

  const ids = [...new Set((memberships || []).map((item) => item.household_id))];
  if (ids.length === 0) {
    if (pantryController) {
      pantryController.destroy();
      pantryController = null;
      activeHouseholdId = null;
    }
    $("#auth-hero").hidden = false;
    $("#workspace-view").hidden = true;
    $("#auth-card").hidden = true;
    $("#workspace-card").hidden = true;
    $("#household-card").hidden = false;
    return;
  }

  const { data: households, error: householdError } = await supabase
    .from("households")
    .select("id, name")
    .in("id", ids);

  if (householdError) throw householdError;

  const household = (households || [])[0];
  const membership = memberships.find((item) => item.household_id === household?.id);
  if (!household || !membership) {
    throw new Error("Your household membership is present, but household details could not be loaded.");
  }

  $("#auth-hero").hidden = true;
  $("#workspace-view").hidden = false;
  $("#auth-card").hidden = true;
  $("#household-card").hidden = true;
  $("#workspace-card").hidden = true;

  if (activeHouseholdId !== household.id || !pantryController) {
    if (pantryController) pantryController.destroy();
    activeHouseholdId = household.id;
    pantryController = mountPantry({
      supabase,
      container: $("#pantry-root"),
      household,
      membership,
      user: currentUser,
      language,
      onSignOut: signOut
    });
  } else {
    await pantryController.reload();
  }
}
async function syncSession(session) {
  currentUser = session?.user ?? null;
  if (!currentUser) {
    if (pantryController) {
      pantryController.destroy();
      pantryController = null;
      activeHouseholdId = null;
    }
    $("#auth-hero").hidden = false;
    $("#workspace-view").hidden = true;
    $("#household-card").hidden = true;
    $("#workspace-card").hidden = true;
    showAuthPanel("signin");
    return;
  }

  try {
    const { data: profile } = await supabase
      .from("profiles")
      .select("preferred_language")
      .eq("id", currentUser.id)
      .maybeSingle();

    if (profile?.preferred_language === "en" || profile?.preferred_language === "hi") {
      language = profile.preferred_language;
      localStorage.setItem("foodsaver_language", language);
      applyLanguage();
    }

    await loadHouseholds();
  } catch (error) {
    showAuthPanel("signin");
    showStatus(friendlyError(error), "error");
  }
}

async function updateProfileLanguage(nextLanguage) {
  if (!currentUser || !supabase) return;
  const { error } = await supabase
    .from("profiles")
    .update({ preferred_language: nextLanguage })
    .eq("id", currentUser.id);
  if (error) console.warn("Could not save language preference:", error.message);
}

$("#language-select").addEventListener("change", async (event) => {
  language = event.target.value === "hi" ? "hi" : "en";
  localStorage.setItem("foodsaver_language", language);
  applyLanguage();
  if (pantryController) pantryController.setLanguage(language);
  await updateProfileLanguage(language);
});

$("#tab-signin").addEventListener("click", () => showAuthPanel("signin"));
$("#tab-signup").addEventListener("click", () => showAuthPanel("signup"));
$("#show-reset").addEventListener("click", () => showAuthPanel("reset"));
$("#back-to-signin").addEventListener("click", () => showAuthPanel("signin"));

$("#signin-form").addEventListener("submit", async (event) => {
  event.preventDefault();
  if (isSubmitting) return;
  const form = event.currentTarget;
  const values = new FormData(form);
  const email = String(values.get("email") || "").trim();
  const password = String(values.get("password") || "");
  isSubmitting = true;
  setBusy(form, true);
  clearStatus();

  try {
    const { data, error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) throw error;
    await syncSession(data.session);
  } catch (error) {
    showStatus(friendlyError(error), "error");
  } finally {
    isSubmitting = false;
    setBusy(form, false);
  }
});

$("#signup-form").addEventListener("submit", async (event) => {
  event.preventDefault();
  if (isSubmitting) return;
  const form = event.currentTarget;
  const values = new FormData(form);
  const name = String(values.get("name") || "").trim();
  const email = String(values.get("email") || "").trim();
  const password = String(values.get("password") || "");
  isSubmitting = true;
  setBusy(form, true);
  clearStatus();

  try {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: { full_name: name, preferred_language: language },
        emailRedirectTo: window.location.origin
      }
    });
    if (error) throw error;

    if (data.session) {
      await syncSession(data.session);
      showStatus(t("signupSuccess"), "success");
    } else {
      showAuthPanel("signin");
      showStatus(t("checkEmail"), "success");
    }
  } catch (error) {
    showStatus(friendlyError(error), "error");
  } finally {
    isSubmitting = false;
    setBusy(form, false);
  }
});

$("#reset-form").addEventListener("submit", async (event) => {
  event.preventDefault();
  if (isSubmitting) return;
  const form = event.currentTarget;
  const email = String(new FormData(form).get("email") || "").trim();
  isSubmitting = true;
  setBusy(form, true);
  clearStatus();

  try {
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: window.location.origin
    });
    if (error) throw error;
    showStatus(t("resetSent"), "success");
  } catch (error) {
    showStatus(friendlyError(error), "error");
  } finally {
    isSubmitting = false;
    setBusy(form, false);
  }
});

$("#new-password-form").addEventListener("submit", async (event) => {
  event.preventDefault();
  if (isSubmitting) return;
  const form = event.currentTarget;
  const password = String(new FormData(form).get("password") || "");
  isSubmitting = true;
  setBusy(form, true);

  try {
    const { error } = await supabase.auth.updateUser({ password });
    if (error) throw error;
    showAuthPanel("signin");
    showStatus(t("passwordUpdated"), "success");
  } catch (error) {
    showStatus(friendlyError(error), "error");
  } finally {
    isSubmitting = false;
    setBusy(form, false);
  }
});

$("#household-form").addEventListener("submit", async (event) => {
  event.preventDefault();
  if (isSubmitting) return;
  const form = event.currentTarget;
  const name = String(new FormData(form).get("name") || "").trim();
  isSubmitting = true;
  setBusy(form, true);

  try {
    const { error } = await supabase.rpc("create_household", { p_name: name });
    if (error) throw error;
    await loadHouseholds();
  } catch (error) {
    showHouseholdStatus(friendlyError(error), "error");
  } finally {
    isSubmitting = false;
    setBusy(form, false);
  }
});

async function signOut() {
  const { error } = await supabase.auth.signOut();
  if (error) showStatus(friendlyError(error), "error");
  else showAuthPanel("signin");
}

$("#household-signout").addEventListener("click", signOut);
$("#workspace-signout").addEventListener("click", signOut);

applyLanguage();

if (!isSupabaseConfigured) {
  $("#connection-indicator").textContent = t("missingConfig");
  $("#connection-indicator").classList.add("bad");
  showStatus(
    "The frontend is ready, but the Supabase URL and publishable key have not been added to the environment yet.",
    "error"
  );
  $("#signin-form").querySelector("button").disabled = true;
  $("#signup-form").querySelector("button").disabled = true;
  $("#reset-form").querySelector("button").disabled = true;
  $("#household-form").querySelector("button").disabled = true;
} else {
  $("#connection-indicator").textContent = t("connected");
  $("#connection-indicator").classList.add("ok");

  supabase.auth.onAuthStateChange((event, session) => {
    if (event === "PASSWORD_RECOVERY") {
      showAuthPanel("new-password");
      return;
    }
    window.setTimeout(() => {
      void syncSession(session);
    }, 0);
  });

  const { data: sessionData, error: sessionError } = await supabase.auth.getSession();
  if (sessionError) showStatus(friendlyError(sessionError), "error");
  await syncSession(sessionData?.session ?? null);
}
