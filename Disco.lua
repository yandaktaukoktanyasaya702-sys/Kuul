--[[
  _____  _     _          _ _       __ 
 |  __ \(_)   | |        | (_)     / _|
 | |  | |_ ___| |__   ___| |_  ___| |_ 
 | |  | | / __| '_ \ / _ \ | |/ _ \  _|
 | |__| | \__ \ |_) |  __/ | |  __/ |  
 |_____/|_|___/_.__/ \___|_|_|\___|_|  
                                       
â–‘â–’â–“â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–“â–’â–‘â–‘â–’â–“â–ˆâ–“â–’â–‘     â–‘â–’â–“â–ˆâ–“â–’â–‘â–‘â–’â–“â–ˆâ–“â–’â–‘â–‘â–’â–“â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–“â–’â–‘ 
â–‘â–’â–“â–ˆâ–“â–’â–‘â–‘â–’â–“â–ˆâ–“â–’â–‘â–’â–“â–ˆâ–“â–’â–‘     â–‘â–’â–“â–ˆâ–“â–’â–‘â–‘â–’â–“â–ˆâ–“â–’â–‘â–’â–“â–ˆâ–“â–’â–‘        
â–‘â–’â–“â–ˆâ–“â–’â–‘â–‘â–’â–“â–ˆâ–“â–’â–‘â–’â–“â–ˆâ–“â–’â–‘     â–‘â–’â–“â–ˆâ–“â–’â–‘â–‘â–’â–“â–ˆâ–“â–’â–‘â–’â–“â–ˆâ–“â–’â–‘        
â–‘â–’â–“â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–“â–’â–‘â–‘â–’â–“â–ˆâ–“â–’â–‘     â–‘â–’â–“â–ˆâ–“â–’â–‘â–‘â–’â–“â–ˆâ–“â–’â–‘â–‘â–’â–“â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–“â–’â–‘  
â–‘â–’â–“â–ˆâ–“â–’â–‘      â–‘â–’â–“â–ˆâ–“â–’â–‘     â–‘â–’â–“â–ˆâ–“â–’â–‘â–‘â–’â–“â–ˆâ–“â–’â–‘      â–‘â–’â–“â–ˆâ–“â–’â–‘ 
â–‘â–’â–“â–ˆâ–“â–’â–‘      â–‘â–’â–“â–ˆâ–“â–’â–‘     â–‘â–’â–“â–ˆâ–“â–’â–‘â–‘â–’â–“â–ˆâ–“â–’â–‘      â–‘â–’â–“â–ˆâ–“â–’â–‘ 
â–‘â–’â–“â–ˆâ–“â–’â–‘      â–‘â–’â–“â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–“â–’â–‘â–’â–“â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–“â–’â–‘â–‘â–’â–“â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–“â–’â–‘  
]]--

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local InsertService = game:GetService("InsertService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local SendNotification = function(Text, Description)
StarterGui:SetCore("SendNotification",{
	Title = Text,
	Text = Description,
	Icon = "rbxassetid://1234567890",
    Duration = 2,
})
end

-- tables
local ScrambleCharacters = {"#", "@", "%", "&", "?", "!", "$", "*", "+", "="}
local ActiveEffects = {}
local AnimatorModule = {}
local ActiveNotifications = {}
local StoredMotors = {}
local TrashBin = {}
local Settings = {
	AnimationBlending = 0.65;
	AnimationSpeed = 1.25;
	Taunts = true;
	Props = true;
	CameraEffects = true;
	InfiniteJump = false;
	Spin = false;
	RigSize = 1;
	Ragdoll = false;
	Music = true;
	FOVEffects = true;
}

local Directories = {
	Main = "FEVerse/",
	RBXMs ="FEVerse/RBXMs/",
	Sounds = "FEVerse/Sounds/",
	Songs = "FEVerse/Songs/",
}

local Reanimate_Settings = {
	Frequency = 6, -- this is basically how fast the oscillation goes
	Amplification = 6, -- this is how far the oscillation goes
	FrontOffset = 2.5, -- this is how much youre in front of the player during prediction
}
local FEManager = loadstring(game:HttpGet("https://gist.githubusercontent.com/MelonsStuff/a003ea305dd302eab1f8d372daed38b4/raw/9db59962b28555fd699a7c29891efb85d45677ab/gistfile1.txt"))()
SendNotification("Disbelief +", "please wait while assets download (skips if you already have them downloaded)")
for i, v in pairs(Directories) do FEManager.EnsureFolder(v) end
FEManager.DownloadFile(Directories.RBXMs, "DisbeliefPlus.rbxm", "https://raw.githubusercontent.com/MelonsStuff/FEVerse/refs/heads/main/RBXMs/DisbeliefPlus.rbxm")

SendNotification("Disbelief +", "please wait while assets load")
local script = InsertService:LoadLocalAsset(getcustomasset(Directories.RBXMs.."DisbeliefPlus.rbxm"))

do
	local Accessories = {}
	local Aligns = {}
	local Attachments = {}
	local BindableEvent = nil
	local Blacklist = {}
	local CFrame = CFrame
	local CFrameidentity = CFrame.identity
	local CFramelookAt = CFrame.lookAt
	local CFramenew = CFrame.new
	local Character = nil
	local CurrentCamera = nil
	local Enum = Enum
	local Custom = Enum.CameraType.Custom
	local Health = Enum.CoreGuiType.Health
	local HumanoidRigType = Enum.HumanoidRigType
	local R6 = HumanoidRigType.R6
	local Dead = Enum.HumanoidStateType.Dead
	local LockCenter = Enum.MouseBehavior.LockCenter
	local UserInputType = Enum.UserInputType
	local MouseButton1 = UserInputType.MouseButton1
	local Touch = UserInputType.Touch
	local Exceptions = {}
	local game = game
	local Clone = game.Clone
	local Close = game.Close
	local Connect = Close.Connect
	local Disconnect = Connect(Close, function() end).Disconnect
	local Wait = Close.Wait
	local Destroy = game.Destroy
	local FindFirstAncestorOfClass = game.FindFirstAncestorOfClass
	local FindFirstAncestorWhichIsA = game.FindFirstAncestorWhichIsA
	local FindFirstChild = game.FindFirstChild
	local FindFirstChildOfClass = game.FindFirstChildOfClass
	local Players = FindFirstChildOfClass(game, "Players")
	local CreateHumanoidModelFromDescription = Players.CreateHumanoidModelFromDescription
	local GetPlayers = Players.GetPlayers
	local LocalPlayer = Players.LocalPlayer
	local CharacterAdded = LocalPlayer.CharacterAdded
	local Mouse = LocalPlayer:GetMouse()
	local Kill = LocalPlayer.Kill
	local RunService = FindFirstChildOfClass(game, "RunService")
	local PostSimulation = RunService.PostSimulation
	local PreRender = RunService.PreRender
	local PreSimulation = RunService.PreSimulation
	local StarterGui = FindFirstChildOfClass(game, "StarterGui")
	local GetCoreGuiEnabled = StarterGui.GetCoreGuiEnabled
	local SetCore = StarterGui.SetCore
	local SetCoreGuiEnabled = StarterGui.SetCoreGuiEnabled
	local Workspace = FindFirstChildOfClass(game, "Workspace")
	local FallenPartsDestroyHeight = Workspace.FallenPartsDestroyHeight
	local HatDropY = FallenPartsDestroyHeight - 0.7
	local FindFirstChildWhichIsA = game.FindFirstChildWhichIsA
	local UserInputService = FindFirstChildOfClass(game, "UserInputService")
	local InputBegan = UserInputService.InputBegan
	local IsMouseButtonPressed = UserInputService.IsMouseButtonPressed
	local GetChildren = game.GetChildren
	local GetDescendants = game.GetDescendants
	local GetPropertyChangedSignal = game.GetPropertyChangedSignal
	local CurrentCameraChanged = GetPropertyChangedSignal(Workspace, "CurrentCamera")
	local MouseBehaviorChanged = GetPropertyChangedSignal(UserInputService, "MouseBehavior")
	local IsA = game.IsA
	local IsDescendantOf = game.IsDescendantOf

	local Highlights = {}

	local Instancenew = Instance.new
	local R15Animation = Instancenew("Animation")
	local R6Animation = Instancenew("Animation")
	local HumanoidDescription = Instancenew("HumanoidDescription")
	local HumanoidModel = CreateHumanoidModelFromDescription(Players, HumanoidDescription, R6)
	local R15HumanoidModel = CreateHumanoidModelFromDescription(Players, HumanoidDescription, HumanoidRigType.R15)
	local SetAccessories = HumanoidDescription.SetAccessories
	local ModelBreakJoints = HumanoidModel.BreakJoints
	local Head = HumanoidModel.Head
	local BasePartBreakJoints = Head.BreakJoints
	local GetJoints = Head.GetJoints
	local IsGrounded = Head.IsGrounded
	local Humanoid = HumanoidModel.Humanoid
	local ApplyDescription = Humanoid.ApplyDescription
	local ChangeState = Humanoid.ChangeState
	local EquipTool = Humanoid.EquipTool
	local GetAppliedDescription = Humanoid.GetAppliedDescription
	local GetPlayingAnimationTracks = Humanoid.GetPlayingAnimationTracks
	local LoadAnimation = Humanoid.LoadAnimation
	local Move = Humanoid.Move
	local UnequipTools = Humanoid.UnequipTools
	local ScaleTo = HumanoidModel.ScaleTo

	local IsFirst = false
	local IsHealthEnabled = nil
	local IsLockCenter = false
	local IsRegistered = false
	local IsRunning = false

	local LastTime = nil

	local math = math
	local mathrandom = math.random
	local mathsin = math.sin
	local mathpi = math.pi

	local nan = 0 / 0

	local next = next

	local OptionsAccessories = nil
	local OptionsApplyDescription = nil
	local OptionsBreakJointsDelay = nil
	local OptionsClickFling = nil
	local OptionsDisableCharacterCollisions = nil
	local OptionsDisableHealthBar = nil
	local OptionsDisableRigCollisions = nil
	local OptionsDefaultFlingOptions = nil
	local OptionsHatDrop = nil
	local OptionsHideCharacter = nil
	local OptionsParentCharacter = nil
	local OptionsRigTransparency = nil
	local OptionsSetCameraSubject = nil
	local OptionsSetCameraType = nil
	local OptionsSetCharacter = nil
	local OptionsSetCollisionGroup = nil
	local OptionsSimulationRadius = nil
	local OptionsTeleportRadius = nil
	local OptionsUseServerBreakJoints

	local osclock = os.clock

	local PreRenderConnection = nil

	local RBXScriptConnections = {}

	local replicatesignal = replicatesignal

	local Rig = nil
	local RigHumanoid = nil
	local RigHumanoidRootPart = nil

	local sethiddenproperty = sethiddenproperty
	local setscriptable = setscriptable

	local stringfind = string.find

	local table = table
	local tableclear = table.clear
	local tablefind = table.find
	local tableinsert = table.insert
	local tableremove = table.remove

	local Targets = {}

	local task = task
	local taskdefer = task.defer
	local taskspawn = task.spawn
	local taskwait = task.wait

	local Time = nil

	local Tools = {}

	local Vector3 = Vector3
	local Vector3new = Vector3.new
	local FlingVelocity = Vector3new(16384, 16384, 16384)
	local HatDropLinearVelocity = Vector3new(0, 27, 0)
	local HideCharacterOffset = Vector3new(0, - 30, 0)
	local Vector3one = Vector3.one
	local Vector3xzAxis = Vector3new(1, 0, 1)
	local Vector3zero = Vector3.zero
	local AntiSleep = Vector3zero

	local Color3fromRGB = Color3.fromRGB

	R15Animation.AnimationId = "rbxassetid://507767968"
	R6Animation.AnimationId = "rbxassetid://180436148"

	Humanoid = nil

	Destroy(HumanoidDescription)
	HumanoidDescription = nil

	local FindFirstChildOfClassAndName = function(Parent, ClassName, Name)
		for Index, Child in next, GetChildren(Parent) do
			if IsA(Child, ClassName) and Child.Name == Name then
				return Child
			end
		end
	end

	local GetHandleFromTable = function(Table)
		for Index, Child in GetChildren(Character) do
			if IsA(Child, "Accoutrement") then
				local Handle = FindFirstChildOfClassAndName(Child, "BasePart", "Handle")

				if Handle then
					local MeshId = nil
					local TextureId = nil

					if IsA(Handle, "MeshPart") then
						MeshId = Handle.MeshId
						TextureId = Handle.TextureID
					else
						local SpecialMesh = FindFirstChildOfClass(Handle, "SpecialMesh")

						if SpecialMesh then
							MeshId = SpecialMesh.MeshId
							TextureId = SpecialMesh.TextureId
						end
					end

					if MeshId then
						if stringfind(MeshId, Table.MeshId) and stringfind(TextureId, Table.TextureId) then
							return Handle
						end
					end
				end
			end
		end
	end

	local NewIndex = function(self, Index, Value)
		self[Index] = Value
	end

	local DescendantAdded = function(Descendant)
		if IsA(Descendant, "Accoutrement") and OptionsHatDrop then
			if not pcall(NewIndex, Descendant, "BackendAccoutrementState", 0) then
				if sethiddenproperty then
					sethiddenproperty(Descendant, "BackendAccoutrementState", 0)
				elseif setscriptable then
					setscriptable(Descendant, "BackendAccoutrementState", true)
					Descendant.BackendAccoutrementState = 0
				end
			end
		elseif IsA(Descendant, "Attachment") then
			local Attachment = Attachments[Descendant.Name]

			if Attachment then
				local Parent = Descendant.Parent

				if IsA(Parent, "BasePart") then
					local MeshId = nil
					local TextureId = nil

					if IsA(Parent, "MeshPart") then
						MeshId = Parent.MeshId
						TextureId = Parent.TextureID
					else
						local SpecialMesh = FindFirstChildOfClass(Parent, "SpecialMesh")

						if SpecialMesh then
							MeshId = SpecialMesh.MeshId
							TextureId = SpecialMesh.TextureId
						end
					end

					if MeshId then
						for Index, Table in next, Accessories do
							if Table.MeshId == MeshId and Table.TextureId == TextureId then
								local Handle = Table.Handle

								tableinsert(Aligns, {
									LastPosition = Handle.Position,
									Offset = CFrameidentity,
									Part0 = Parent,
									Part1 = Handle
								})

								return
							end
						end

						for Index, Table in next, OptionsAccessories do
							if stringfind(MeshId, Table.MeshId) and stringfind(TextureId, Table.TextureId) then
								local Instance = nil
								local TableName = Table.Name
								local TableNames = Table.Names

								if TableName then
									Instance = FindFirstChildOfClassAndName(Rig, "BasePart", TableName)
								else
									for Index, TableName in next, TableNames do
										local Child = FindFirstChildOfClassAndName(Rig, "BasePart", TableName)

										if not ( TableNames[Index + 1] and Blacklist[Child] ) then
											Instance = Child
											break
										end
									end
								end

								if Instance then
									local Blacklisted = Blacklist[Instance]

									if not ( Blacklisted and Blacklisted.MeshId == MeshId and Blacklisted.TextureId == TextureId ) then
										tableinsert(Aligns, {
											Offset = Table.Offset,
											Part0 = Parent,
											Part1 = Instance
										})

										Blacklist[Instance] = { MeshId = MeshId, TextureId = TextureId }

										return
									end
								end
							end
						end

						local Accoutrement = FindFirstAncestorWhichIsA(Parent, "Accoutrement")

						if Accoutrement and IsA(Accoutrement, "Accoutrement") then
							local AccoutrementClone = Clone(Accoutrement)

							local HandleClone = FindFirstChildOfClassAndName(AccoutrementClone, "BasePart", "Handle")
							HandleClone.Transparency = OptionsRigTransparency

							for Index, Descendant in next, GetDescendants(HandleClone) do
								if IsA(Descendant, "JointInstance") then
									Destroy(Descendant)
								end
							end

							local AccessoryWeld = Instancenew("Weld")
							AccessoryWeld.C0 = Descendant.CFrame
							AccessoryWeld.C1 = Attachment.CFrame
							AccessoryWeld.Name = "AccessoryWeld"
							AccessoryWeld.Part0 = HandleClone
							AccessoryWeld.Part1 = Attachment.Parent
							AccessoryWeld.Parent = HandleClone

							AccoutrementClone.Parent = Rig

							tableinsert(Accessories, {
								Handle = HandleClone,
								MeshId = MeshId,
								TextureId = TextureId
							})
							tableinsert(Aligns, {
								Offset = CFrameidentity,
								Part0 = Parent,
								Part1 = HandleClone
							})
						end
					end
				end
			end
		end
	end

	local SetCameraSubject = function()
		local CameraCFrame = CurrentCamera.CFrame
		local Position = RigHumanoidRootPart.CFrame.Position

		CurrentCamera.CameraSubject = RigHumanoid
		Wait(PreRender)
		CurrentCamera.CFrame = CameraCFrame + RigHumanoidRootPart.CFrame.Position - Position
	end

	local OnCameraSubjectChanged = function()
		if CurrentCamera.CameraSubject ~= RigHumanoid then
			taskdefer(SetCameraSubject)
		end
	end

	local OnCameraTypeChanged = function()
		if CurrentCamera.CameraType ~= Custom then
			CurrentCamera.CameraType = Custom
		end
	end

	local OnCurrentCameraChanged = function()
		local Camera = Workspace.CurrentCamera

		if Camera and OptionsSetCameraSubject then
			CurrentCamera = Workspace.CurrentCamera

			taskspawn(SetCameraSubject)

			OnCameraSubjectChanged()
			tableinsert(RBXScriptConnections, Connect(GetPropertyChangedSignal(CurrentCamera, "CameraSubject"), OnCameraSubjectChanged))

			if OptionsSetCameraType then
				OnCameraTypeChanged()
				tableinsert(RBXScriptConnections, Connect(GetPropertyChangedSignal(CurrentCamera, "CameraType"), OnCameraTypeChanged))
			end
		end
	end

	local SetCharacter = function()
		LocalPlayer.Character = Rig
	end

	local SetSimulationRadius = function()
		LocalPlayer.SimulationRadius = OptionsSimulationRadius
	end

	local WaitForChildOfClass = function(Parent, ClassName)
		local Child = FindFirstChildOfClass(Parent, ClassName)

		while not Child do
			Wait(Parent.ChildAdded)
			Child = FindFirstChildOfClass(Parent, ClassName)
		end

		return Child
	end

	local WaitForChildOfClassAndName = function(Parent, ...)
		local Child = FindFirstChildOfClassAndName(Parent, ...)

		while not Child do
			Wait(Parent.ChildAdded)
			Child = FindFirstChildOfClassAndName(Parent, ...)
		end

		return Child
	end

	local Fling = function(Target, Options)
		if Target then
			local Highlight = Options.Highlight

			if IsA(Target, "Humanoid") then
				Target = Target.Parent
			end
			if IsA(Target, "Model") then
				Target = FindFirstChildOfClassAndName(Target, "BasePart", "HumanoidRootPart") or FindFirstChildWhichIsA(Character, "BasePart")
			end

			if not tablefind(Targets, Target) and IsA(Target, "BasePart") and not Target.Anchored and not IsDescendantOf(Character, Target) and not IsDescendantOf(Rig, Target) then
				local Model = FindFirstAncestorOfClass(Target, "Model")

				if Model and FindFirstChildOfClass(Model, "Humanoid") then
					Target = FindFirstChildOfClassAndName(Model, "BasePart", "HumanoidRootPart") or FindFirstChildWhichIsA(Character, "BasePart") or Target	
				else
					Model = Target
				end

				if Highlight then
					local HighlightObject = type(Highlight) == "boolean" and Highlight and Instancenew("Highlight") or Clone(Highlight)
					HighlightObject.Adornee = Model
					HighlightObject.Parent = Model
					HighlightObject.OutlineColor = Color3fromRGB(255, 0, 0)
					HighlightObject.FillColor = Color3fromRGB(0, 0, 0)

					Options.HighlightObject = HighlightObject
					tableinsert(Highlights, HighlightObject)
				end

				Targets[Target] = Options
			end
		end
	end

	local OnCharacterAdded = function(NewCharacter)
 
		if NewCharacter ~= Rig then
			tableclear(Aligns)
			tableclear(Blacklist)

			Character = NewCharacter

			if OptionsSetCameraSubject then
				taskspawn(SetCameraSubject)
			end

			if OptionsSetCharacter then
				taskdefer(SetCharacter)
			end

			if OptionsParentCharacter then
				Character.Parent = Rig
			end

			for Index, Descendant in next, GetDescendants(Character) do
				taskspawn(DescendantAdded, Descendant)
			end

			tableinsert(RBXScriptConnections, Connect(Character.DescendantAdded, DescendantAdded))

			Humanoid = WaitForChildOfClass(Character, "Humanoid")
			local HumanoidRootPart = WaitForChildOfClassAndName(Character, "BasePart", "HumanoidRootPart")

			if IsFirst then
				if OptionsApplyDescription and Humanoid then
					local AppliedDescription = GetAppliedDescription(Humanoid)
					SetAccessories(AppliedDescription, {}, true)
					taskspawn(ApplyDescription, RigHumanoid, AppliedDescription)
				end

				if HumanoidRootPart then
					RigHumanoidRootPart.CFrame = HumanoidRootPart.CFrame

					if OptionsSetCollisionGroup then
						local CollisionGroup = HumanoidRootPart.CollisionGroup

						for Index, Descendant in next, GetDescendants(Rig) do
							if IsA(Descendant, "BasePart") then
								Descendant.CollisionGroup = CollisionGroup
							end
						end
					end
				end

				IsFirst = false
			end

			local IsAlive = true

			if HumanoidRootPart then
				for Target, Options in next, Targets do
					if IsDescendantOf(Target, Workspace) then
						local FirstPosition = Target.Position
						local PredictionFling = Options.PredictionFling
						local LastPosition = FirstPosition
						local Timeout = osclock() + Options.Timeout or 1

						if HumanoidRootPart then
							while IsDescendantOf(Target, Workspace) and osclock() < Timeout do
								local DeltaTime = taskwait()
								local Position = Target.Position

								if ( Position - FirstPosition ).Magnitude > 100 then
									break
								end

								local Offset = Vector3zero

								if PredictionFling then
									local BaseOffset = (Position - LastPosition) / DeltaTime * 0.13
									local Frequency = Reanimate_Settings.Frequency
									local Amplification = Reanimate_Settings.Amplification
									local Time = tick()
									local TargetFace = Target.CFrame.LookVector
									local Oscillation = mathsin(Time * mathpi * 2 * Frequency) * Amplification
									local OscillatedOffset = TargetFace * Oscillation
									local FrontFaceOffset = TargetFace * Reanimate_Settings.FrontOffset
									Offset = BaseOffset + OscillatedOffset + FrontFaceOffset
								end

								HumanoidRootPart.AssemblyAngularVelocity = FlingVelocity
								HumanoidRootPart.AssemblyLinearVeloci
