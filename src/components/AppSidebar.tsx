import { 
  BarChart3, 
  Home, 
  Package, 
  Users, 
  UserPlus, 
  Gift, 
  Share2, 
  FileText, 
  User,
  LogOut,
  Shield,
  Settings,
  ChevronLeft,
  ChevronRight,
  Sun,
  Moon
} from "lucide-react";
import { useNavigate, useLocation } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { useToast } from "@/hooks/use-toast";
import { useAuth } from "@/contexts/AuthContext";
import { ThemeToggle } from "@/components/ThemeToggle";
import { useTheme } from "@/hooks/useTheme";
import { useState } from "react";
import { motion } from "framer-motion";
import { cn } from "@/lib/utils";

export function AppSidebar() {
  const navigate = useNavigate();
  const location = useLocation();
  const { toast } = useToast();
  const { user, logout, hasPermission } = useAuth();
  const { theme, setTheme } = useTheme();
  const [isCollapsed, setIsCollapsed] = useState(false);

  const menuItems = [
    {
      label: "Dashboard",
      href: "/dashboard",
      icon: Home,
      permission: "view_dashboard"
    },
    {
      label: "Beneficiários",
      href: "/beneficiarios", 
      icon: Users,
      permission: "manage_beneficiaries"
    },
    {
      label: "Cadastro de Pessoas",
      href: "/cadastro-pessoas",
      icon: UserPlus,
      permission: "manage_beneficiaries"
    },
    {
      label: "Doações",
      href: "/doacoes",
      icon: Gift,
      permission: "manage_donations"
    },
    {
      label: "Estoque",
      href: "/estoque",
      icon: Package,
      permission: "manage_stock"
    },
    {
      label: "Distribuição",
      href: "/distribuicao",
      icon: Share2,
      permission: "manage_distributions"
    },
    {
      label: "Relatórios",
      href: "/relatorios",
      icon: BarChart3,
      permission: "view_reports"
    },
    {
      label: "Perfil",
      href: "/perfil",
      icon: User,
      permission: null // Todos podem acessar
    }
  ];

  const adminMenuItems = [
    {
      label: "Gestão de Usuários",
      href: "/gestao-usuarios",
      icon: Shield,
      permission: "manage_users"
    },
    {
      label: "Configurações",
      href: "/configuracoes",
      icon: Settings,
      permission: "system_settings"
    }
  ];

  const handleLogout = () => {
    logout();
    toast({
      title: "Logout realizado",
      description: "Até logo!",
    });
    navigate("/");
  };

  const filteredMenuItems = menuItems.filter(item => 
    !item.permission || hasPermission(item.permission)
  );

  const filteredAdminItems = adminMenuItems.filter(item => 
    hasPermission(item.permission)
  );

  const getRoleBadge = () => {
    if (!user || !user.role) return null;
    
    const variants = {
      superadmin: { variant: "destructive", label: "Super Admin" },
      admin: { variant: "default", label: "Admin" }, 
      voluntario: { variant: "secondary", label: "Voluntário" }
    };
    
    const config = variants[user.role as keyof typeof variants];
    
    if (!config) {
      console.warn(`Unknown user role: ${user.role}`);
      return null;
    }
    
    return (
      <Badge variant={config.variant as any} className="text-xs">
        {config.label}
      </Badge>
    );
  };

  const handleLinkClick = (href: string) => {
    navigate(href);
  };

  return (
    <div className="flex">
      {/* Desktop Sidebar */}
      <motion.div
        className={cn(
          "hidden md:flex flex-col bg-neutral-100 dark:bg-neutral-800 border-r border-neutral-200 dark:border-neutral-700 h-screen sticky top-0"
        )}
        animate={{
          width: isCollapsed ? "80px" : "280px",
        }}
        transition={{
          duration: 0.3,
          ease: "easeInOut",
        }}
      >
        {/* Header */}
        <div className="p-4 border-b border-neutral-200 dark:border-neutral-700">
          {!isCollapsed ? (
            // Layout expandido
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <img 
                    src="/sanem_logo_transparent.png" 
                    alt="SANEM Logo" 
                    className="h-8 w-8 object-contain flex-shrink-0"
                  />
                  <motion.div
                    initial={false}
                    animate={{ opacity: 1 }}
                    transition={{ duration: 0.2 }}
                  >
                    <h2 className="text-xl font-bold text-neutral-800 dark:text-neutral-200">SANEM</h2>
                  </motion.div>
                </div>
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => setIsCollapsed(true)}
                  className="h-8 w-8 p-0"
                >
                  <ChevronLeft className="h-4 w-4" />
                </Button>
              </div>
            </div>
          ) : (
            // Layout colapsado - Logo centralizada com seta ao lado
            <div className="flex items-center justify-between w-full">
              <img 
                src="/sanem_logo_transparent.png" 
                alt="SANEM Logo" 
                className="h-8 w-8 object-contain"
              />
              <Button
                variant="ghost"
                size="sm"
                onClick={() => setIsCollapsed(false)}
                className="h-8 w-8 p-0"
              >
                <ChevronRight className="h-4 w-4" />
              </Button>
            </div>
          )}
          
          {/* User Info */}
          {user && !isCollapsed && (
            <motion.div 
              className="mt-3 p-3 bg-neutral-50 dark:bg-neutral-900 rounded-lg border border-neutral-200 dark:border-neutral-700"
              initial={false}
              animate={{ opacity: isCollapsed ? 0 : 1 }}
              transition={{ duration: 0.2 }}
            >
              <div className="flex items-center justify-between">
                <div className="min-w-0 flex-1">
                  <p className="text-sm font-medium text-neutral-800 dark:text-neutral-200 truncate">{user.name}</p>
                  <p className="text-xs text-neutral-600 dark:text-neutral-400 truncate">{user.email}</p>
                </div>
                <div className="ml-2">
                  {getRoleBadge()}
                </div>
              </div>
            </motion.div>
          )}
        </div>

        {/* Navigation */}
        <div className="flex-1 overflow-y-auto p-4">
          {/* Menu Principal */}
          <div className="mb-6">
            {!isCollapsed && (
              <motion.p 
                className="text-xs font-semibold text-neutral-500 dark:text-neutral-400 uppercase tracking-wider mb-3"
                initial={false}
                animate={{ opacity: isCollapsed ? 0 : 1 }}
                transition={{ duration: 0.2 }}
              >
                Menu Principal
              </motion.p>
            )}
            <div className="space-y-1">
              {filteredMenuItems.map((item) => {
                const Icon = item.icon;
                const isActive = location.pathname === item.href;
                
                return (
                  <div
                    key={item.href}
                    onClick={() => handleLinkClick(item.href)}
                    className={cn(
                      "flex items-center gap-3 px-3 py-2 rounded-md cursor-pointer transition-colors",
                      isActive 
                        ? "bg-neutral-200 dark:bg-neutral-700 text-neutral-900 dark:text-neutral-100" 
                        : "text-neutral-700 dark:text-neutral-300 hover:bg-neutral-200 dark:hover:bg-neutral-700"
                    )}
                  >
                    <Icon className="h-5 w-5 flex-shrink-0" />
                    {!isCollapsed && (
                      <motion.span
                        className="text-sm font-medium truncate"
                        initial={false}
                        animate={{ opacity: isCollapsed ? 0 : 1 }}
                        transition={{ duration: 0.2 }}
                      >
                        {item.label}
                      </motion.span>
                    )}
                  </div>
                );
              })}
            </div>
          </div>

          {/* Menu Admin */}
          {filteredAdminItems.length > 0 && (
            <div className="mb-6">
              {!isCollapsed && (
                <motion.p 
                  className="text-xs font-semibold text-neutral-500 dark:text-neutral-400 uppercase tracking-wider mb-3"
                  initial={false}
                  animate={{ opacity: isCollapsed ? 0 : 1 }}
                  transition={{ duration: 0.2 }}
                >
                  Administração
                </motion.p>
              )}
              <div className="space-y-1">
                {filteredAdminItems.map((item) => {
                  const Icon = item.icon;
                  const isActive = location.pathname === item.href;
                  
                  return (
                    <div
                      key={item.href}
                      onClick={() => handleLinkClick(item.href)}
                      className={cn(
                        "flex items-center gap-3 px-3 py-2 rounded-md cursor-pointer transition-colors",
                        isActive 
                          ? "bg-neutral-200 dark:bg-neutral-700 text-neutral-900 dark:text-neutral-100" 
                          : "text-neutral-700 dark:text-neutral-300 hover:bg-neutral-200 dark:hover:bg-neutral-700"
                      )}
                    >
                      <Icon className="h-5 w-5 flex-shrink-0" />
                      {!isCollapsed && (
                        <motion.span
                          className="text-sm font-medium truncate"
                          initial={false}
                          animate={{ opacity: isCollapsed ? 0 : 1 }}
                          transition={{ duration: 0.2 }}
                        >
                          {item.label}
                        </motion.span>
                      )}
                    </div>
                  );
                })}
              </div>
            </div>
          )}
        </div>

        {/* Footer - Theme Toggle e Logout */}
        <div className="p-4 border-t border-neutral-200 dark:border-neutral-700">
          <div className="space-y-1">
            {/* Theme Toggle */}
            <div 
              onClick={() => setTheme(theme === "light" ? "dark" : "light")}
              className={cn(
                "flex items-center gap-3 px-3 py-2 rounded-md cursor-pointer transition-colors text-neutral-700 dark:text-neutral-300 hover:bg-neutral-200 dark:hover:bg-neutral-700",
                isCollapsed ? "justify-center" : ""
              )}
            >
              <div className="h-5 w-5 flex items-center justify-center">
                <Sun className="h-4 w-4 rotate-0 scale-100 transition-all dark:-rotate-90 dark:scale-0" />
                <Moon className="absolute h-4 w-4 rotate-90 scale-0 transition-all dark:rotate-0 dark:scale-100" />
              </div>
              {!isCollapsed && (
                <motion.span
                  className="text-sm font-medium"
                  initial={false}
                  animate={{ opacity: isCollapsed ? 0 : 1 }}
                  transition={{ duration: 0.2 }}
                >
                  Alterar tema
                </motion.span>
              )}
            </div>
            
            {/* Logout Button */}
            <div 
              onClick={handleLogout}
              className="flex items-center gap-3 px-3 py-2 rounded-md cursor-pointer transition-colors text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20"
            >
              <LogOut className="h-5 w-5 flex-shrink-0" />
              {!isCollapsed && (
                <motion.span
                  className="text-sm font-medium"
                  initial={false}
                  animate={{ opacity: isCollapsed ? 0 : 1 }}
                  transition={{ duration: 0.2 }}
                >
                  Sair
                </motion.span>
              )}
            </div>
          </div>
        </div>
      </motion.div>

      {/* Mobile Sidebar */}
      <div className="md:hidden">
        {/* Mobile menu button */}
        <div className="fixed top-4 left-4 z-50">
          <Button
            variant="outline"
            size="sm"
            onClick={() => setIsCollapsed(!isCollapsed)}
            className="h-10 w-10 p-0"
          >
            {isCollapsed ? (
              <ChevronRight className="h-4 w-4" />
            ) : (
              <ChevronLeft className="h-4 w-4" />
            )}
          </Button>
        </div>

        {/* Mobile sidebar overlay */}
        {!isCollapsed && (
          <motion.div
            initial={{ x: "-100%" }}
            animate={{ x: 0 }}
            exit={{ x: "-100%" }}
            transition={{ duration: 0.3, ease: "easeInOut" }}
            className="fixed inset-0 z-40 bg-white dark:bg-neutral-900 p-6"
          >
            <div className="flex flex-col h-full">
              {/* Header */}
              <div className="flex items-center justify-between mb-6">
                <div className="flex items-center gap-2">
                  <img 
                    src="/sanem_logo_transparent.png" 
                    alt="SANEM Logo" 
                    className="h-8 w-8 object-contain"
                  />
                  <h2 className="text-xl font-bold text-neutral-800 dark:text-neutral-200">SANEM</h2>
                </div>
                {/* Theme Toggle for Mobile */}
                <ThemeToggle />
              </div>

              {/* User Info */}
              {user && (
                <div className="mb-6 p-3 bg-neutral-50 dark:bg-neutral-800 rounded-lg">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm font-medium text-neutral-800 dark:text-neutral-200">{user.name}</p>
                      <p className="text-xs text-neutral-600 dark:text-neutral-400">{user.email}</p>
                    </div>
                    {getRoleBadge()}
                  </div>
                </div>
              )}

              {/* Navigation */}
              <div className="flex-1 overflow-y-auto">
                {/* Menu Principal */}
                <div className="mb-6">
                  <p className="text-xs font-semibold text-neutral-500 dark:text-neutral-400 uppercase tracking-wider mb-3">
                    Menu Principal
                  </p>
                  <div className="space-y-1">
                    {filteredMenuItems.map((item) => {
                      const Icon = item.icon;
                      const isActive = location.pathname === item.href;
                      
                      return (
                        <div
                          key={item.href}
                          onClick={() => {
                            handleLinkClick(item.href);
                            setIsCollapsed(true);
                          }}
                          className={cn(
                            "flex items-center gap-3 px-3 py-3 rounded-md cursor-pointer transition-colors",
                            isActive 
                              ? "bg-neutral-200 dark:bg-neutral-700 text-neutral-900 dark:text-neutral-100" 
                              : "text-neutral-700 dark:text-neutral-300 hover:bg-neutral-100 dark:hover:bg-neutral-800"
                          )}
                        >
                          <Icon className="h-5 w-5" />
                          <span className="text-sm font-medium">{item.label}</span>
                        </div>
                      );
                    })}
                  </div>
                </div>

                {/* Menu Admin */}
                {filteredAdminItems.length > 0 && (
                  <div className="mb-6">
                    <p className="text-xs font-semibold text-neutral-500 dark:text-neutral-400 uppercase tracking-wider mb-3">
                      Administração
                    </p>
                    <div className="space-y-1">
                      {filteredAdminItems.map((item) => {
                        const Icon = item.icon;
                        const isActive = location.pathname === item.href;
                        
                        return (
                          <div
                            key={item.href}
                            onClick={() => {
                              handleLinkClick(item.href);
                              setIsCollapsed(true);
                            }}
                            className={cn(
                              "flex items-center gap-3 px-3 py-3 rounded-md cursor-pointer transition-colors",
                              isActive 
                                ? "bg-neutral-200 dark:bg-neutral-700 text-neutral-900 dark:text-neutral-100" 
                                : "text-neutral-700 dark:text-neutral-300 hover:bg-neutral-100 dark:hover:bg-neutral-800"
                            )}
                          >
                            <Icon className="h-5 w-5" />
                            <span className="text-sm font-medium">{item.label}</span>
                          </div>
                        );
                      })}
                    </div>
                  </div>
                )}
              </div>

              {/* Logout Button */}
              <div className="pt-4 border-t border-neutral-200 dark:border-neutral-700">
                <div 
                  onClick={handleLogout}
                  className="flex items-center gap-3 px-3 py-3 rounded-md cursor-pointer transition-colors text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20"
                >
                  <LogOut className="h-5 w-5" />
                  <span className="text-sm font-medium">Sair</span>
                </div>
              </div>
            </div>
          </motion.div>
        )}
      </div>
    </div>
  );
}
