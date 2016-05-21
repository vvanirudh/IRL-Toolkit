Inverse Reinforcement Learning Toolkit

Sergey Levine, 2011

1. Introduction
2. Installation
3. Usage
    3.1 Running a single test
    3.2 Running a transfer test
    3.3 Running a series of tests
    3.4 Using human generated examples
4. Directory overview
    4.1 IRL algorithms
    4.2 MDP solvers
    4.3 Example domains
    4.4 General
5. Calling conventions
    5.1 IRL algorithms
    5.2 MDP solvers
    5.3 Example domains
6. License

1. Introduction

This MATLAB package contains a collection of inverse reinforcement learning
algorithms and a framework for evaluating these algorithms on a variety of
simple Markov decision processes. The package is distributed primarily as the
reference implementation for the Gaussian Process Inverse Reinforcement Learning
algorithm described in the paper "Nonlinear Inverse Reinforcement Learning with
Gaussian Processes" (Levine, Popovic, Koltun, NIPS 2011), but is also intended
to provide a general-purpose framework for researchers interested in inverse
reinforcement learning. This file describes the contents of the package,
provides instructions regarding its use, instructions for extending the package
with new algorithms, solvers, and example domains, and finally contains the
license under which the package may be used and distributed.

2. Installation

The IRL toolkit was built with MATLAB R2009b. Earlier version of MATLAB may be
sufficient, but were not tested. In addition to MATLAB R2009b and various
toolboxes, which may include the Statistics and Parallelism toolboxes, the
package requires the following external MATLAB scripts:

- minFunc, by Mark Schmidt, included with this package (Creative Commons by-nc,
    see <http://www.cs.ubc.ca/~schmidtm/Software/minFunc.html> for details)
- CVX, by Michael C. Grant and Stephen P. Boyd, included with this package (GPL)
- plot2svg, by Juerg Schwizer, included with this package (FreeBSD)

With the exception of CVX, none of the scripts require installation.
Installation consists of two easy steps:

	1. Extract all files in irl_toolkit.zip into a desired directory.
	2. Run Utilities/cvx_setup to install CVX.

3. Usage

This section briefly describes how to use the IRL toolkit. The toolkit is
designed to be modular and extendable. Most sessions will begin by running
"addpaths" in the main directory, to add all necessary subdirectories to the
path. Optionally, you may save your MATLAB path to avoid needing to do this, but
this is left up to you, since some users may prefer not to clutter up their
path.

3.1 Running a single test

An example script for running a test is provided under the name singletest.m in
the main directory. This script calls "addpaths" to add the necessary paths, and
then runs a single test using GPIRL on a 32x32 objectworld environment. The
function "runtest" creates a random environment of a specified type, creates
synthetic examples (or, optionally, uses provided human generated examples), and
calls the specified IRL algorithm to determine the reward function. The result
of the IRL algorithm is evaluated according to a set of provided metrics, and
the results are returned in a single structure. The arguments of runtest are the
following:

	1. Algorithm name. This always corresponds to the name of the directory
        containing the algorithm, which is also the prefix of every function for that
        algorithm.
	2. Algorithm parameters. This is a struct containing the desired parameters for
        this algorithm. For more information, see <algorithm name>defaultparams.m in
        the desired algorithm's directory.
	3. MDP type. This is the MDP solver used to generate synthetic examples. By
        default, two options are available: standardmdp, which uses the standard
        Bellman equations, and linearmdp, which uses the LMDP framework.
	4. Example name. This is the directory name/prefix of the environment to be
        tested.
	5. Example parameters. These are the parameters of the test environment. See
        <example name>defaultparams.m in the desired example's directory.
	6. Test parameters. These are parameters of the test itself, including the
        number of examples. See General/setdefaultparams.m for details.

A quick way to view the results of the test is provided by the printresults
function. The visualize function renders the results of the test to the screen,
with a side by side comparison of the true and learned reward functions.

3.2 Running a transfer test

To run a transfer test -- that is, to test how well a learned reward function
generalizes to another state space, -- use the runtransfertest function. The
arguments of this function are the following:

	1. IRL results returned by runtest. If runtest returns test_result, this is
        test_result.irl_result
	2. Algorithm name, as before.
	3. MDP type.
	4. Example name. Should be the same as the example in the original test.
	5. Example parameters. These may be different from the original test (in
        fact, they should be to test any interesting transfer). However, some
        parameters may be incompatible -- for example, in the objectworld, the
        number of features depends on "n", so testing transfer with a different
        values of "n" will not work when using discrete features.
	6. Transfer test parameters. See General/settransferdefaultparams.m for
        details.

The results of the transfer test can similarly be printed and viewed using
printresults and visualize.

3.3 Running a series of tests

The functions runtestseries and runtransferseries can be used to run a large
series of tests, using a variety of algorithms and parameter settings. The
package contains scripts for graphing and saving the results of such tests.
Examples of how to use these functions can be found in the NIPS11_Tests
directory, which contains the scripts that were used to produce the graphs in
the 2011 NIPS paper (note that, due to code changes since publication and
randomized initialization, the results produced by these scripts may differ
slightly from those presented in the paper). All of these scripts use the
Parallelism toolbox to run multiple tests in parallel for efficiency, and call
the saveresults function at the end to save the results from the test into a
directory with a name corresponding to the test and the current time and date.
Once this directory is created, the results can be graphed using the
renderresults function, which takes the directory name as the first argument.
The second argument specifies whether to only graph the results (1), or whether
to also render the reward function of each test (0), which takes significantly
longer.

3.4 Using human generated examples

The directory Human_Demos contains some demonstrations of highway policies by a
human user. To pass these examples to a test, set the "true_examples" field of
the test parameters struct (last argument to runtest) to
human_result.example_samples after loading the desired demo. Note that the test
should be done using the same example parameters, which can be obtained from
human_result.mdp_params.

To generate your own human demonstrations, use the tools in HumanControl.
Specifically, the runhumantrial function will bring up an interface for
generating a human demonstration. This interface is currently "turn based",
although a real time interface may be added in the future. The arguments for
this function are the following:

	1. Example name.
	2. Example parameters.
	3. Human trial parameters specifying the number and length of examples. See
        HumanControl/humantrialdefaultparams.m

The function returns a human_result struct, which can be saved and used for
future tests.

4. Directory overview

This section presents an overview of the directories in the package, briefly
describing each included IRL algorithm, MDP solver, and example domain.

4.1 IRL algorithms

Note that, with the exception of FIRL and GPIRL, I cannot vouch for the accuracy
of my implementations of prior algorithms. While I made a best faith effort to
implement these methods correctly based on the authors' descriptions, these are
my own implementations and should not be viewed as the definitive reference
implementations of the prior algorithms.

	- AN - Abbeel & Ng's projection algorithm for inverse reinforcement learning.
Note that, since Abbeel & Ng's algorithm does not return a single reward, this
implementation is somewhat less accurate than the original algorithm, because a
single reward function must be selected to return for evaluation. For details,
see "Apprenticeship Learning via Inverse Reinforcement Learning" (Abbeel and Ng,
ICML 2004) 
	- FIRL - The Feature Construction for Inverse Reinforcement Learning algorithm.
Only compatible with discrete features (the "continuous" parameter must be set
to 0 for the current example environment). For details, see "Feature
Construction for Inverse Reinforcement Learning" (Levine, Popovic, Koltun, NIPS
2010)
	- GPIRL - The Gaussian Process Inverse Reinforcement Learning algorithm. For
continuous features, it is recommended to use the warped kernel by setting the
"warp_x" parameter to 1. For details, see "Nonlinear Inverse Reinforcement
Learning with Gaussian Processes" (Levine, Popovic, Koltun, NIPS 2011)
	- LEARCH - An implement of the "Learning to Search" algorithm. This is a "best
effort" implementation, since the algorithm is quite complicated and has many
free parameters. The current version can run either log-linear mode or
nonlinear, with decision trees of logistic regression to create nonlinear
features. For details, see "Learning to Search: Functional Gradient Techniques
for Imitation Learning" (Ratliff, Silver, Bagnell, Autonomous Robots 27 (1)
2009)
	- MaxEnt - the maximum entropy IRL algorithm. For details, see "Maximum Entropy
Inverse Reinforcement Learning" (Ziebart, Mass, Bagnell, Dey, AAAI 2008)
	- MMP - the maximum margin planning algorithm. Note that this implementation
uses the QP formulation of MMP rather than subgradient methods, since the QP
version is already very fast on the examples in this package. For details, see
"Maximum Margin Planning" (Ratliff, Bagnell, Zinkevich, ICML 2006)
	- MMPBoost - MMP with feature boosting, using decision trees of a configurable
depth. As with LEARCH, this is a "best effort" implementation, since the
algorithm has many free parameters. For details, see "Boosting Structured
Prediction for Imitation Learning" (Ratliff, Bradley, Bagnell, Chestnutt, NIPS
2007)
	- MWAL - The game-theoretic MWAL algorithm. For details, see "A Game-Theoretic
Approach to Apprenticeship Learning" (Syed, Schapire, NIPS 2008)
	- OptV - A provisional implementation of the OptV algorithm. Since OptV learns
value functions rather than reward functions, this algorithm cannot use the
provided features, and instead simply learns a value for each state. This makes
it unable to perform transfer, and produces (unfairly) poor results compared to
the other methods. It should be noted that this is a symptom of the framework
rather than the algorithm, since the toolkit is designed for testing algorithms
that learn rewards rather than value functions. For details, see "Inverse
Optimal Control with Linearly-Solvable MDPs" (Dvijotham, Todorov, ICML 2010)

4.2 MDP solvers

The toolkit comes with two MDP solvers. The standard solver (StandardMDP) uses
value iteration to recover a value function, which in turn specifies a
deterministic optimal policy for the MDP. The linear MDP solver (LinearMDP) uses
"soft" value iteration as described in Ziebart's PhD thesis, and corresponds to
linearly-solvable MDPs (see Dvijotham & Todorov 2010). This model produces
stochastic examples, which may be viewed as "suboptimal" under the standard MDP
model.

4.3 Example domains

Three example domains are included in this toolkit. They are described below:

	- Gridworld - This is an NxN gridworld, with 5 actions per state corresponding
to moving in each direction and staying in place. The "determinism" parameter
specifies the probability that each action will "succeed." If the action
"fails," a different random action is taken instead. The reward function of the
gridworld consists of BxB blocks of cells (forming a "super grid"). The features
are indicators for x and y values being below various integer values. Note that
this environment does not support transfer experiments.
	- Objectworld - This is a gridworld populated with objects. Each object has one
of C inner and outer colors, and the objects are placed at random. There are 2C
continuous features, each giving the Euclidean distance to the nearest object
with a specific inner or outer color. In the discrete feature case, there are
2CN binary features, each one an indicator for a corresponding continuous
feature being less than some value D. The true reward is positive in states that
are both within 3 cells of outer color 1 and 2 cells of outer color 2, negative
within 3 cells of outer color 1, and zero otherwise. Inner colors and all other
outer colors are distractors.
	- Highway - This is the highway environment described in "Nonlinear Inverse
Reinforcement Learning with Gaussian Processes." Note that the number of cars on
the highway must be specified manually. There is a somewhat hacky algorithm for
placing cars that avoids creating roadblocks. This algorithm will stall if it
cannot be placed the specified number of cars, so don't specify too many. This
may be fixed in a future release. It is also possible to specify more than 2
categories or classes of cars, though this functionality is currently untested.

4.4 General

The following are miscallaneous directories in the toolkit:

	- Evaluation - This directory contains implementations of the various metrics
that can be used to evaluate the IRL result. Each function is a particular
metric.
	- General - These are general testing scripts, including runtest,
runtransfertest, etc.
	- HumanControl - Interface for generating human demonstrations.
	- NIPS11_Tests - Scripts for reproducing test results from "Nonlinear Inverse
Reinforcement Learning with Gaussian Processes."
	- Testing - Scripts for graphing, saving, and visualizing test results from
series tests.
	- Utilities - External utilities, including minFunc and CVX.

5. Calling conventions

The IRL toolkit is intended to be extendable and modular. This section describes
the calling convention for various modules, in order to describe how additional
components can be added. So long as the new component implements the specified
functions, it will be usable with the toolkit.

5.1 IRL algorithms

IRL algorithms should must implement two functions: <name>run and
<name>transfer, where <name> is the name of the algorithm that will be used to
identify it when calling runtest. Additionally, all current algorithms implement
<name>defaultparams, but this is a convenience. The run function must accept the
following arguments:

	1. algorithm_params - The parameters of the algorithm. Some parameters may be
missing, so it is advisable to implement a <name>defaultparams function to fill
them in (for example, see gpirldefaultparams.m).
	2. mdp_data - A specification of the example domain. mdp_data includes the
number of states, the number of actions, the transition function (specified by
sa_s and sa_p), and so forth. For details, see (for example) gridworldbuild.m
	3. mdp_model - The name of the current MDP model (standardmdp or linearmdp).
The final returned policy must be computed from the reward function using this
model, but most algorithms will not use this parameter anywhere else.
	4. feature_data - Information about the features. The main paramater of this
struct is feature_data.splittable (forgive the "legacy" name), which is a matrix
containing the value of each feature at each state.
	5. example_samples - A cell array of the examples, where exmaple_samples{i,t}
is time step t along trajectory i. Each entry in the cell array has two numbers:
example_samples{i,t}(1) is the state, and example_samples{i}{t}(2) is the
action.
	6. true_features - The true features that form a linear basis for the reward.
Most algorithms (that are not cheating) will ignore this, but it may be useful
for establishing a baseline comparison.
	7. verbosity - The desired amount of output. 0 means no output, 1 means
"medium" output, and 2 means "verbose" output.

Additionally, IRL algorithms must return the struct irl_result containing the
result of the computation. This struct has the following fields:

	1. r - the learned reward function, with mdp_data.states rows and
mdp_data.actions columns
	2. v - the resulting value function, returned by <mdp_model>solve
	3. p - the corresponding policy (as above)
	4. q - the corresponding q function (as above)
	5. r_itr - the reward at each iteration of the algorithm, useful for debugging;
if unused, set to {{r}}
	6. model_itr - the model at each iteration of the algorithm, to be used for
transfer
	7. model_r_itr - a second optional reward at each iteration of the algorithm,
useful for debugging; if unused, set to r_itr
	8. p_itr - the policy at each iteration; if unused, set to {{p}}
	9. model_p_itr - a second optional policy at each iteration of the algorithm,
useful for debugging; if unused, set to p_itr
	10. time - the time the algorithm spent computing the reward function
(optional, set to 0 if unused)

The transfer function must use the learned model to transfer the reward function
to a different state space. The output of this function is identical to
<name>run. The arguments are the following:

	1. prev_result - The irl_result structure returned by a <name>run call.
	2. mdp_data - MDP definition for the new state space.
	3. mdp_model - MDP model, as before.
	4. feature_data - Feature data for the new state space.
	5. true_feature_map - True features for the new state space (again, not used
except when "cheating").
	6. verbosity - As before.

If both <name>run and <name>transfer are implemented, the algorithm should be
usable in all tests without further modification.

5.2 MDP solvers

Additional MDP solvers can also be added to the framework, for example for
solving problems with continuous state spaces. The MDP solver must implement 5
functions: <name>solve, <name>frequency, <name>action, <name>step, and
<name>compare.

The function <name>solve must find the solution to the specified MDP. It has two
arguments: mdp_data, the MDP definition, and the states x actions reward r. The
definition mdp_data is constructed by the example building function (see 5.3).
The output is a struct "mdp_solution", which has fields "v", "q", and "p",
corresponding to the value function, Q function, and policy. Note that these
fields will only be used by other functions relating to your MDP solver, so they
can contain whatever information you choose.

The function <name>frequency finds the visitation frequency of all states in the
MDP. This function is used by many metrics. The inputs are mdp_data and
mdp_solution (from a previous call to <name>solve), and the output is a column
vector with 1 entry for each state, giving that state's expected visitation
count under the policy in mdp_solution.

The functions <name>action and <name>step sample an action at a particular state
and execute that action, respectively. <name>action takes as input mdp_data,
mdp_solution, and a state s. The output is an action a, which is either the
optimal action under a deterministic policy or a sampled action under a
stochastic policy. The function <name>step takes mdp_data, mdp_solution, a state
s, and an action a, and returns the resulting state after taking action a in
state s, which may be sampled if the MDP is nondeterministic.

Finally, the function <name>compare compares two policies, given as arguments p1
and p2, and returns the amount of discrepancy between them. In the case of a
standard MDP, this is currently the number of states in which the policies
disagree. In the case of the linear MDP, this is the sum over all states of the
probability that p1 and p2 will take different actions. This function is only
used when evaluating some metrics.

5.3 Example domains

Example domains are only required to implement two functions: <name>build and
<name>draw. The building function has a single argument - the mdp_params
structure passed to runtest that specifies the parameters of the desired
example. The outputs are the following:

	1. mdp_data - A structure containing the definition of the MDP. It must specify
the following fields:
		- states - the number of states
		- actions - the number of actions in each state
		- discount - the discount factor of the MDP (currently all examples are
infinite horizon discounted reward)
		- sa_s - 3D matrix of size states x actions x K, where K is any number. The
entry sa_s(s,a,k) specifies the state to transition to when taking action a in
state s, and sampling destination k (see below)
		- sa_p - 3D matrix as above, where sa_p(s,a,k) gives the probability of
transitioning to sa_s(s,a,k) on action a in state s
	2. r - A states x actions matrix specifying the true reward function of the
example environment.
	3. feature_data - A struct containing two fields regarding the features of the
example:
		- splittable a states x features matrix containing the value of each feature
at each state
		- stateadjacency - A sparse states x states matrix with "1" for each pair of
states that are "adjacent" (have an action to transition from one to the other);
this is currently only used by FIRL.
	4. true_feature_map - A (sparse) states x features matrix that gives the values
of the "true" features that can be linearly combined to obtain r.

The drawing function has no output, and takes the following input arguments:

	1. r - The reward function to draw.
	2. p - The policy to draw (may be deterministic or stochastic).
	3. mdp_params - The mdp_params struct passed to <name>build.
	4. mdp_data - The mdp_data struct returned by <name>build.
	5. feature_data - The feature_data struct returned by <name>build.
	6. model - The MDP model (standardmdp or linearmdp).

The drawing function must draw some visualization of the specified example to
the current axes.

6 License

The license included below governs the terms of use for this software. Please
direct any correspondence regarding the software to svlevine@cs.stanford.edu.
The IRL toolkit is created by Sergey Levine, copyright 2011. If you are using
the software in an academic publication, you may cite it as "IRL Toolkit" with a
reference to the webpage from which it was obtained.

Copyright (c) 2011, Sergey Levine
All rights reserved.

This software is made available under the Creative Commons 
Attribution-Noncommercial License, viewable at
http://creativecommons.org/licenses/by-nc/3.0/. You are free to use, copy,
modify, and re-distribute the work.  However, you must attribute any
re-distribution or adaptation in the manner specified below, and you may not
use this work for commercial purposes without the permission of the author.

Any re-distribution or adaptation of this work must contain the author's name 
(Sergey Levine) and a link to the software's original webpage.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
POSSIBILITY OF SUCH DAMAGE.
