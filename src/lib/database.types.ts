export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.18"
  }
  public: {
    Tables: {
      food_categories: {
        Row: {
          key: string
          label_en: string
          label_hi: string
          sort_order: number
        }
        Insert: {
          key: string
          label_en: string
          label_hi: string
          sort_order?: number
        }
        Update: {
          key?: string
          label_en?: string
          label_hi?: string
          sort_order?: number
        }
        Relationships: []
      }
      household_invitations: {
        Row: {
          accepted_at: string | null
          accepted_by: string | null
          created_at: string
          email: string
          expires_at: string
          household_id: string
          id: string
          invited_by: string
          revoked_at: string | null
          token_hash: string
        }
        Insert: {
          accepted_at?: string | null
          accepted_by?: string | null
          created_at?: string
          email: string
          expires_at?: string
          household_id: string
          id?: string
          invited_by: string
          revoked_at?: string | null
          token_hash: string
        }
        Update: {
          accepted_at?: string | null
          accepted_by?: string | null
          created_at?: string
          email?: string
          expires_at?: string
          household_id?: string
          id?: string
          invited_by?: string
          revoked_at?: string | null
          token_hash?: string
        }
        Relationships: [
          {
            foreignKeyName: "household_invitations_household_id_fkey"
            columns: ["household_id"]
            isOneToOne: false
            referencedRelation: "households"
            referencedColumns: ["id"]
          },
        ]
      }
      household_members: {
        Row: {
          can_log_others_consumption: boolean
          can_log_own_consumption: boolean
          can_manage_inventory: boolean
          can_manage_members: boolean
          can_record_waste: boolean
          can_view_household_analytics: boolean
          household_id: string
          id: string
          joined_at: string
          role: string
          user_id: string
        }
        Insert: {
          can_log_others_consumption?: boolean
          can_log_own_consumption?: boolean
          can_manage_inventory?: boolean
          can_manage_members?: boolean
          can_record_waste?: boolean
          can_view_household_analytics?: boolean
          household_id: string
          id?: string
          joined_at?: string
          role?: string
          user_id: string
        }
        Update: {
          can_log_others_consumption?: boolean
          can_log_own_consumption?: boolean
          can_manage_inventory?: boolean
          can_manage_members?: boolean
          can_record_waste?: boolean
          can_view_household_analytics?: boolean
          household_id?: string
          id?: string
          joined_at?: string
          role?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "household_members_household_id_fkey"
            columns: ["household_id"]
            isOneToOne: false
            referencedRelation: "households"
            referencedColumns: ["id"]
          },
        ]
      }
      households: {
        Row: {
          created_at: string
          id: string
          name: string
          owner_user_id: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          id?: string
          name: string
          owner_user_id: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          id?: string
          name?: string
          owner_user_id?: string
          updated_at?: string
        }
        Relationships: []
      }
      inventory_movements: {
        Row: {
          actor_user_id: string
          base_unit: string
          consumed_by_user_id: string | null
          created_at: string
          household_id: string
          id: string
          movement_type: string
          pantry_item_id: string
          quantity_delta: number
          reason: string | null
          reversal_of_id: string | null
        }
        Insert: {
          actor_user_id: string
          base_unit: string
          consumed_by_user_id?: string | null
          created_at?: string
          household_id: string
          id?: string
          movement_type: string
          pantry_item_id: string
          quantity_delta: number
          reason?: string | null
          reversal_of_id?: string | null
        }
        Update: {
          actor_user_id?: string
          base_unit?: string
          consumed_by_user_id?: string | null
          created_at?: string
          household_id?: string
          id?: string
          movement_type?: string
          pantry_item_id?: string
          quantity_delta?: number
          reason?: string | null
          reversal_of_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "inventory_movements_household_id_fkey"
            columns: ["household_id"]
            isOneToOne: false
            referencedRelation: "households"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "inventory_movements_pantry_item_id_household_id_fkey"
            columns: ["pantry_item_id", "household_id"]
            isOneToOne: false
            referencedRelation: "pantry_items"
            referencedColumns: ["id", "household_id"]
          },
          {
            foreignKeyName: "inventory_movements_reversal_of_id_fkey"
            columns: ["reversal_of_id"]
            isOneToOne: true
            referencedRelation: "inventory_movements"
            referencedColumns: ["id"]
          },
        ]
      }
      pantry_items: {
        Row: {
          alert_days_before: number
          archived_at: string | null
          base_unit: string
          category_key: string
          created_at: string
          created_by: string
          display_unit: string
          expiry_date: string | null
          household_id: string
          id: string
          name: string
          notes: string | null
          quantity_base: number
          storage_location_id: string | null
          updated_at: string
          updated_by: string | null
        }
        Insert: {
          alert_days_before?: number
          archived_at?: string | null
          base_unit: string
          category_key: string
          created_at?: string
          created_by?: string
          display_unit: string
          expiry_date?: string | null
          household_id: string
          id?: string
          name: string
          notes?: string | null
          quantity_base?: number
          storage_location_id?: string | null
          updated_at?: string
          updated_by?: string | null
        }
        Update: {
          alert_days_before?: number
          archived_at?: string | null
          base_unit?: string
          category_key?: string
          created_at?: string
          created_by?: string
          display_unit?: string
          expiry_date?: string | null
          household_id?: string
          id?: string
          name?: string
          notes?: string | null
          quantity_base?: number
          storage_location_id?: string | null
          updated_at?: string
          updated_by?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "pantry_items_category_key_fkey"
            columns: ["category_key"]
            isOneToOne: false
            referencedRelation: "food_categories"
            referencedColumns: ["key"]
          },
          {
            foreignKeyName: "pantry_items_household_id_fkey"
            columns: ["household_id"]
            isOneToOne: false
            referencedRelation: "households"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "pantry_items_storage_location_id_household_id_fkey"
            columns: ["storage_location_id", "household_id"]
            isOneToOne: false
            referencedRelation: "storage_locations"
            referencedColumns: ["id", "household_id"]
          },
        ]
      }
      profiles: {
        Row: {
          created_at: string
          display_name: string
          id: string
          preferred_language: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          display_name?: string
          id: string
          preferred_language?: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          display_name?: string
          id?: string
          preferred_language?: string
          updated_at?: string
        }
        Relationships: []
      }
      storage_locations: {
        Row: {
          created_at: string
          created_by: string
          household_id: string
          id: string
          is_active: boolean
          name: string
          sort_order: number
          updated_at: string
        }
        Insert: {
          created_at?: string
          created_by?: string
          household_id: string
          id?: string
          is_active?: boolean
          name: string
          sort_order?: number
          updated_at?: string
        }
        Update: {
          created_at?: string
          created_by?: string
          household_id?: string
          id?: string
          is_active?: boolean
          name?: string
          sort_order?: number
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "storage_locations_household_id_fkey"
            columns: ["household_id"]
            isOneToOne: false
            referencedRelation: "households"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      accept_household_invitation: {
        Args: { p_token: string }
        Returns: string
      }
      add_inventory_stock: {
        Args: { p_pantry_item_id: string; p_quantity_base: number }
        Returns: string
      }
      adjust_inventory_stock: {
        Args: { p_pantry_item_id: string; p_quantity_delta_base: number }
        Returns: string
      }
      create_household: { Args: { p_name: string }; Returns: string }
      create_household_invitation: {
        Args: { p_email: string; p_household_id: string; p_token_hash: string }
        Returns: string
      }
      record_consumption: {
        Args: {
          p_consumed_by_user_id?: string
          p_pantry_item_id: string
          p_quantity_base: number
        }
        Returns: string
      }
      record_food_waste: {
        Args: {
          p_pantry_item_id: string
          p_quantity_base: number
          p_reason?: string
        }
        Returns: string
      }
      reverse_inventory_movement: {
        Args: { p_movement_id: string }
        Returns: string
      }
      update_household_member_permissions: {
        Args: {
          p_can_log_others_consumption?: boolean
          p_can_log_own_consumption?: boolean
          p_can_manage_inventory?: boolean
          p_can_manage_members?: boolean
          p_can_record_waste?: boolean
          p_can_view_household_analytics?: boolean
          p_member_id: string
          p_role?: string
        }
        Returns: undefined
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends (DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never) = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends (PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never) = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {},
  },
} as const
