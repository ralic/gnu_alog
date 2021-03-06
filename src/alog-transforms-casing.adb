--
--  Copyright (c) 2008,
--  Reto Buerki, Adrian-Ken Rueegsegger
--  secunet SwissIT AG
--
--  This file is part of Alog.
--
--  Alog is free software; you can redistribute it and/or modify
--  it under the terms of the GNU Lesser General Public License as published
--  by the Free Software Foundation; either version 2.1 of the License, or
--  (at your option) any later version.
--
--  Alog is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU Lesser General Public License for more details.
--
--  You should have received a copy of the GNU Lesser General Public License
--  along with Alog; if not, write to the Free Software
--  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston,
--  MA  02110-1301  USA
--

with Ada.Characters.Handling;

package body Alog.Transforms.Casing is

   -------------------------------------------------------------------------

   procedure Set_Mode
     (Transform : in out Instance;
      Mode      :        Operation_Mode)
   is
   begin
      Transform.Mode := Mode;
   end Set_Mode;

   -------------------------------------------------------------------------

   function Transform_Message
     (Transform : Instance;
      Level     : Log_Level := Info;
      Msg       : String)
      return String
   is
      pragma Unreferenced (Level);
   begin
      if Transform.Mode = Lowercase then
         return Ada.Characters.Handling.To_Lower (Msg);
      else
         return Ada.Characters.Handling.To_Upper (Msg);
      end if;
   end Transform_Message;

end Alog.Transforms.Casing;
