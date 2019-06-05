% System Dynamics

%%%% INPUT
%
%       --------- Joing Angle --------  ------ Joint Velocity --------
%       -- Two Link --  -- One Link --  -- Two Link --  -- One Link --
% Q = [     q1; q2;         q;              q1d; q2d;       qd        ]
% 
%       -- Two Link --  -- One Link -- 
% F = [       F1;           F2;       ]

%%%% OUTPUT
%       ------ Joint Velocity --------  ------ Joint Velocity --------
%       -- Two Link --  -- One Link --  -- Two Link --  -- One Link --
% Q = [     q1d; q2d;       qd;             q1dd; q2dd;     qdd       ]

function [Qd, data] = systemDynamics(t, Q)

% State variable decomposition
Q_OneLink = [Q(3, 1); Q(6, 1)];
Q_TwoLink = [Q(1:2, 1); Q(4:5, 1)];


% Controller design 
%
% Two link: (haptics)
u_TwoLink = twoLinkController_Haptics(Q_TwoLink, Q_OneLink);
% Two link: (human impedance)
x_dsr_Twolink = 0.05; % 0.2*deg2rad(30)*sin(1*pi*t); % 
F_TwoLink = twoLinkController_HumanImpedance(Q_TwoLink, x_dsr_Twolink);
Qd_TwoLink = twoLinkDynamics(t, Q_TwoLink, F_TwoLink, u_TwoLink);
%

% One link: (controller)
u_OneLink = oneLinkController_JacobianInverse(Q_TwoLink, Q_OneLink);
% One link: (contact)
F_OneLink = 0;
Qd_OneLink = oneLinkDynamics(t, Q_OneLink, F_OneLink, u_OneLink);



Qd = [Qd_TwoLink(1:2, 1); Qd_OneLink(1, 1); Qd_TwoLink(3:4, 1); Qd_OneLink(2, 1)];

% Data Saving
[x_TwoLink, ~, ~] = twoLinkKinematics(Q_TwoLink);
[x_OneLink, ~, ~] = oneLinkKinematics(Q_OneLink);
data.err = x_TwoLink - x_OneLink; 
data.x_TwoLink = x_TwoLink;
data.x_OneLink = x_OneLink;

end

