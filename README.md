[Русский](#русский) | [English](#english)

## English

FlowLab is a software package for the numerical solution of two-dimensional Navier–Stokes equations in the Boussinesq approximation on a collocation grid in a rectangular domain. The package supports the simulation of melting processes.

* The primary purpose of the software is research and education, including Xcode training and the study of numerical experiments.

* The main physical processes are convection, both natural and forced, in an incompressible fluid with heat transfer and melting.

* The numerical method is based on the finite-difference method on a collocation grid.

* Supported calculation modes include user-defined parameters and parallel computations using multiple threads.

* Project status: actively under development. The core functionality has been implemented. The software is stable, but individual configurations still require additional testing.

- [Description](#description)
- [Physical and mathematical model](#physical-and-mathematical-model)
- [Numerical-method](#numerical-method)
- [Additional-features](#additional-features)
- [Visualization](#visualization)
- [Project-structure](#project-structure)
- [Requirements](#requirements)
- [Installation-and-running-a-simulation](#installation-and-running-a-simulation)
- [Input-parameters](#input-parameters)
- [Output-data](#output-data)
- [Examples](#examples)
- [Performance](#performance)
- [Model-limitations](#model-limitations)
- [License](#license)
- [Contacts](#contacts)

## Description

The software models:

* two-dimensional convective heat transfer and phase-boundary motion;
* a rectangular cavity with solid walls; the walls may be stationary or may move to model melting;
* Navier–Stokes equations in the Boussinesq approximation, including the phase-transition model;
* use in educational and research projects in accordance with the MIT License.

## Physical and mathematical model

> **Symbols (SI system):** 
𝐕 - velocity vector, 
T - temperature, 
p - pressure, 
t - time, 
$\mathbf{g}$ - gravity vector, 
α - thermal diffusivity, 
λ - thermal conductivity, 
β - volume expansion, 
ν - cinematic viscosity, 
L - latent heat, 
n - normal to the surface, 
ρ - density (liquid), ψ, ω - stream function.

The following equations are solved:

* Momentum equation:

$$
\frac{\partial \mathbf{V}}{\partial t}+(\mathbf{V}\cdot\nabla)\mathbf{V}
=-\frac{1}{\rho}\nabla p+\nu\nabla^2\mathbf{V}+\mathbf{g}\beta(T-T_0).
$$

* Energy equation:

$$
\frac{\partial T}{\partial t}+\mathbf{V}\cdot\nabla T=\alpha\nabla^2T.
$$

* Incompressibility condition:

$$
\nabla\cdot\mathbf{V}=0.
$$

* Initial conditions:

$$
\mathbf{V}=0,\qquad T=T_0,
$$

  where $T_0$ is a constant temperature, or a linear temperature distribution from $T_{\max}$ to $T_{\min}$. On a selected section of a hot wall, the temperature may also be specified as a constant value.

* Boundary conditions:

  the no-slip condition is applied on all walls, except for the sections used to model an inflow and an outflow. A constant temperature or a heat flux is specified on the left and right boundaries. Adiabatic conditions are applied to the horizontal walls.

* Reference temperature for β calculations:

$$
T_0=\frac{T_{\max}+T_{\min}}{2}.
$$

* Melting is calculated using the Stefan condition:

$$
-\lambda\frac{dT}{dn}=\rho_{solid}\cdot L\frac{dn}{dt}.
$$

* The phase-transition boundary is described by a level-set function.

* The gravitational acceleration is assumed to have a constant magnitude and a direction that is either constant in time or changes according to the specified configuration.

* Thermal properties α, ν, β, λ may depend on temperature. Interpolation formulas are used for temperature-dependent properties.

* Matter is modeled using the following materials:
  water, air without melting, different paraffin materials, and substances with arbitrary (but temperature-independed thermal properties) user-defined properties.

## Numerical method

* The finite-difference method is used on a collocation grid. Field values are calculated and stored at grid nodes.

* Two phase-transition models are supported and may also be used for flows without melting:

  * ALE — Arbitrary Lagrangian–Eulerian method;
  * EPM — Enthalpy–Porous Media method.

* Convective terms inside the domain are calculated using an explicit UPWIND second-order scheme. The first-order scheme is used near the boundaries to improve stability.

* Diffusion terms are calculated using an implicit scheme with Thomas-algorithm (TDMA) sweeps.

* Pressure is calculated iteratively at every time step. The SIMPLE (Jacobi) method is used for the ALE model, while the Gauss–Seidel method is used for the EPM model. The Rie–Chow interpolation and a checkerboard-pattern prevention procedure are also applied.

* The ALE model uses a nonuniform grid with an increasing step size from the boundaries toward the center, based on a hyperbolic-sine distribution.

* The EPM model uses a uniform square grid.

* The time step is adjusted automatically. The settings include control parameters for the iterative pressure solver and automatic time-step reduction when divergence is detected.

* The calculation is stopped when a specified time or a specified melt volume or melt thickness is reached.

## Additional features

The EPM model supports the simulation of solid objects being introduced into a fluid, both with and without melting. An effective thermal-conductivity model is used in case of solid objects.

The solid object may initially have the melting temperature $T_{\{cold}}$. It then undergoes the melting process under the influence of thermal conductivity.
> **Note:** The EPM method assumes the existence of a "melting interval" where $T_{\{cold}}$ is lower than $T_{\{melt}}$ by a small amount (0.01°C by default).

During the simulation, the state of each time step is saved at specified time intervals. This data is used to generate the simulation history.

## Visualization

The entire calculation process is displayed on a single screen as parameter values, fields, and graphs. On compact devices such as an iPhone, scrolling is used. The simulation is controlled using a touch panel, a mouse, or a trackpad, as well as keyboard shortcuts. The interface is in English and is intuitive.

The visualization screen contains the following areas:

> **note** - if an external keyboard is used, button presses can be duplicated using hotkeys highlighted in blue

* **Control panel:** contains buttons
1) Start/Pause - start/pause the solving process, 
2) History - saving History frames to a file using JSON or a compressed binary format. Loading History frames from a list of files,
> **note** - after loading the file, you can proceed with the calculation; however, some parameters need to be adjusted if the calculation session is already configured for a different task
3) Reset - the initial state of fields and variables is set, with the exception of time, 
4) Diagnostics - a pop-up window displaying diagnostic parameters and graphs, with the ability to switch the graph content and initiate the iterative process for calculating the stream function ω from the Poisson equation, 
5) Settings - pop-up window with adjustable solution process parameters, 
6) Acceleration commands - disables the Main chart area to speed up calculations.

* **Information panel:** displays the gravitational acceleration, flow velocity, solution parameters, grid properties, substance properties, process parameters, and the current time step. The time step may be adjusted manually.

* **Graph controls:** used to select a graph and activate the melting visualization, as well as to select the thermal-map display mode.

* **History pop-up window:** displays the saved simulation history with a frame player (start/stop also by pressing the space bar).

* **Main chart area:** displays thermal maps with an optional velocity field overlay, temperature and pressure isolines, streamlines with flow-direction arrows, temperature graphs in horizontal sections, heat-flow-in-time graphs on vertical boundaries, and the solid-object insertion editor.

* **Diagnostics pop-up window.** see comment 4) to Control panel.

* **Settings pop-up window.** see comment 5) to Control panel and in detail in the section [Input-parameters](#input-parameters).

> An example of the initial screen is provided in the `Examples` section.

## Project structure

All files contain `MARK` comments in English and sufficient comments in Russian. Although the source code is written in English, the meaning of properties and methods is also reflected in their names.

* The main project target is located in the `Navier-Stokes` folder. This folder contains the data model, history manager, solver, and visualizer.

* The data model contains the following files:
  a final solver class with publicly available fields and parameters, computational parameters and properties, model materials with their properties, global parameters, temperature parameters, and state-storage parameters.

* The history manager contains files with parameters and methods for controlling state storage, including saving and loading the simulation history to and from disk in various formats, with data compression.

* The solver contains folders and files used to control the solution of the equations.

* The visualizer contains folders and files used to display the output data.

## Requirements

The project was started in June 2025 and is intended for current versions of iOS and Xcode.

The current configuration uses:

- iOS 26;
- Xcode 26;
- Apple M1 processor;
- macOS;
- iPhone 15.

The code may also work on older platforms because it uses only the following frameworks:

- `Foundation`;
- `SwiftUI`;
- `Combine`;
- `UniformTypeIdentifiers`.

## Installation and running a simulation

1. Download the project to your computer.
2. Open the executable project file.
3. Enter your account details.
4. Select the required `release` XCode configuration.
5. Run the application.

> **Notes:** 1) By default, the application uses the `Custom` material, a simulation time of 60 seconds. Diagnostics can be enabled in the application settings. 2) The computer does not enter sleep mode during the calculation.

## Input parameters

All parameters required for the test convection simulation in a square cavity are preconfigured.

> **Note:** To enter values in text and numeric fields, the change must be confirmed by pressing the Return key and then tapping the keyboard-dismiss button.

The following parameters can be modified in the **Settings** panel:

* **Solution method:** ALE or EPM.

* **Melting:** can be enabled or disabled. For EPM - the melting interval ($T_{\{melt}}$ - $T_{\{cold}}$) can be specified.

* **Concurence:** the parallel computation mode can also be enabled or disabled for different equation-solving methods.

* **Cavity geometry:** number of grid nodes, cavity length and width, and initial melt thickness for the EPM method.

* **Gravity:** initial angle and the angle variation rate in degrees per second or day. The thermal map may be synchronized with the simulation time (or with the physical model in melting mode). For forced convection, the magnitude may be equal to zero.

* **Time parameters:** total simulation time, final time at which the simulation is stopped, final value of the relative volume (thickness) increment of the melt, simulation time step for recording to History, and the time scale used to accelerate the simulation for meltimg. Increasing the time scale reduces the accuracy of the solution.

* **Simulation controls:** the Courant-number range used to adapt the time step (including the hybrid scheme, which is not recommended); pressure-solver tolerance and relax factor; the number of iterations for the Poisson equation; limits of array dimensions for Diagnostics parameters and Hostory.

* **Object parameters:** heating type (T or q), heating value; initial temperature distribution in the cavity; temperature conditions when the phase boundary is crossed; phase-transition temperature; and material (substance) selection for modeling. Any substance may be selected.  Parameters of Custom substance may be modified.

* **Forced convection:** can be enabled or disabled. The inflow may be located at the top or bottom boundary by default, or at the left boundary. The following parameters can be specified:
  flow velocity, temperature excess relative to the temperature specified on the hot wall, inflow angle, and inflow-section coordinates.

## Output data

The simulation data is displayed in the visualizer, mainly in real time and also in the simulation history player.

The main data includes:

* temperature and pressure thermal maps;
* streamlines with velocity arrows;
* temperature-distribution graphs for horizontal sections;
* heat-flow graphs for vertical walls;
* Diagnostics data.

Diagnostics data is not changed or deleted when the simulation history is playing.

## Examples

* **fig. 1** Initial state after the first application launch. 
<img width="1256" height="973" alt="fig1" src="https://github.com/user-attachments/assets/78f96d9f-ffdc-49f3-8109-820fe5910b3f" />

* Visualization screen for an ALE-based simulation without melting in a cavity with diagnostic plots. The simulation time is 90 seconds:

  1. **fig. 2** intermediate state (t=60s) with streamlines shown as a thermal map
  <img width="1256" height="973" alt="fig2" src="https://github.com/user-attachments/assets/17880486-2851-4e2e-a5a4-d2bd292ff906" />

  2. **fig. 3** temperature field shown as a thermal map
  <img width="1256" height="973" alt="fig3" src="https://github.com/user-attachments/assets/18d796a6-9726-47eb-b35a-5c88ac235300" />
  > **Comment:** It is evident that the temperature field is nearly uniform due to intense mixing, with significant gradients present only near the vertical boundaries. The streamlines are closed, indicating the cellular nature of the flow.
  
* Previous example based on the EPM method:

  1. **fig. 4** temperature field
  <img width="1256" height="973" alt="fig4" src="https://github.com/user-attachments/assets/0b9f946d-9851-46d4-a6b9-312db8f4c71c" />
  2. **fig. 4a** heat fluxes at the walls, q(t)
  <img width="1256" height="973" alt="fig4a" src="https://github.com/user-attachments/assets/31523b26-594f-4e5f-b176-6d1a3f4580b8" />

  > **Comment:** The stationary flow field has not yet reached a steady state also. The difference between the flows is caused by the dependence of thermal conductivity on temperature. The figures show the result of the simulation at the **Spent** time compared with the ALE method by using a non-uniform grid. Attention should also be drawn to the differences in results and diagnostics arising from the use of different pressure calculation methods.

* Example of a temperatute field (ALE method) for water melting with an initial melt thickness of 0.3 of the height:
fig. 5

* Example of a temperature field using the EPM method for water with an ice block inserted at a certain stage into the upper part of the cavity and a heat-conducting object in the center. The initial melt thickness is 0.3 relative to the cavity width:
fig. 6

* Example of an EPM temperature field for paraffin melting under zero gravity, with liquid-phase inflow and free outflow at the left boundary:
fig. 7

* Example of an EPM temperature field for natural convection in an air cavity with a gravity angle of 30 degrees:
fig. 8

  > **Comment:** For air, the amplitude of value fluctuations (as seen in the diagnostics graphs) is more pronounced due to its lower viscosity and density compared to paraffins and water; consequently, the non-stationary phase in the calculations is longer. Nevertheless, a trend toward the isotherms aligning perpendicular to the direction of gravity is already discernible.

## Performance

The following techniques are used to improve performance:

* all two-dimensional arrays of floating-point values are converted into one-dimensional arrays;

* in computationally intensive loops, internal-point arrays are homogeneous (pointers type) and are accessed using indices to avoid allocating a large number of temporary arrays;

* thermal-map and diagnostics visualization is disabled during calculations (is recommended);

* parallel calculations are supported for the main equation-solving processes. However, due to significant overhead, parallel calculations may be slower than serial calculations for smaller grids. Additional experiments are required.

## Model limitations

Only laminar flows of an incompressible fluid are considered.

The Prandtl and Rayleigh numbers are calculated using their actual values. The temperature difference must not exceed 40 degrees; temperature-dependent physical properties are interpolated over this range.

The smallest tested grid size is 40 × 40. The largest tested grid size is 300 × 300. The grid stretching factors must not exceed 3.0, since it affects stability and convergence.

Calculation precision is limited by the Double type.

## License

The MIT License text is provided in the `LICENSE.md` file.

## Contacts

Email: `apezera@icloud.com`, `apezera@yandex.ru`

Comments and suggestions are welcome.

[Русский](#русский) | [English](#english)

## Русский

FlowLab — программный комплекс для численного решения двумерных уравнений Навье–Стокса в приближении Буссинеска на коллокационной сетке в прямоугольной области с возможностью моделирования процессов плавления.

* Назначение программы - исследовательские и учебные цели: для обучения XCode и численных экспериментов;

* основные физические процессы: конвекция (естественная и вынужденная) в несжимаемой жидкости с теплопереносом и плавлением;

* используемый численный подход: метод конечных разностей на коллокационной сетке;

* поддерживаемые режимы расчёта: расчёт по заданным пользователем параметрам, а также параллельный расчёт с использованием нескольких потоков.

* статус проекта: в активной разработке. Основная функциональность реализована. Программа стабильно работает: Требуется тестирование отдельных вариантов.

- [Описание](#описание)
- [Физическая и математическая модель](#физическая-и-математическая-модель)
- [Численный метод](#численный-метод)
- [Дополнительные возможности](#дополнительные-возможности)
- [Визуализация](#визуализация)
- [Структура проекта](#структура-проекта)
- [Требования](#требования)
- [Установка и запуск расчета](#установка-и-запуск-расчета)
- [Входные параметры](#входные-параметры)
- [Выходные данные](#выходные-данные)
- [Примеры расчетов](#примеры-расчетов)
- [Производительность](#производительность)
- [Ограничения модели](#ограничения-модели)
- [Лицензия](#лицензия)
- [Контакты](#контакты)


## Описание

* моделируется двумерный конвективноый перенос тепла, а также движение границы разделе фаз;
* геометрия - прямоугольная полость и раздвижные границы (изменения границы раздела фаз при плавлении);
* уравнения - Навье-Стокса в приближении Буссинеска, фазовый переход - формула Стефана;
* использование - в учебных и исследовательских целях, в соответствии с Лицензией.

## Физическая и математическая модель

> **Обозначения (система СИ):** 𝐕 - вектор скорости, T - температура, p - давление, t - время, ḡ - вектор гравитации, α - температуропроводность, λ - теплопроводность, β - коэффициент объемного расширения, ν - кинематическая вязкость, L - скрытая теплота плавления, n - нормаль к поверхности, ρ - плотность жидкой фазы, ψ, ω - функция тока. 

Решаются уравнения
* Импульса: ∂𝐕/∂t + (𝐕・∇)𝐕 = -(1/ρ)∇p + ν∇²𝐕 + ḡβ(Τ-Τ₀).
* Энергии: ∂T/∂t + (𝐕·∇)T = α∇²T.
* Неразрывности: ∇𝐕 = 0.
* Начальные условия: 𝐕 = 0, T - постоянная температура или линейное по ширине распределение от $T_{max}$ до $T_{min}$, а также 𝐕 = const на определенном участке горячей стенки.
* Граничные условия: прилипание на всех границах (за исключением участков вдува и стока), постоянная температура или тепловой поток на левой и правой границах, адиабатные условия на горизонтальных стенках.
* Обозначения стандартные для задач теплофизики. Референсная температурва $T_0=\frac{T_{\max}+T_{\min}}{2}$.

* Плавление: при плавлении на границе разделе фаз используется формула Стефана $-\lambda\frac{dT}{dn}=\rho_{solid}\cdot L\frac{dn}{dt}$.

* Гравитация ḡ: применяется вектор гравитации, имеющий постоянную магнитуду и переменный во времени или постоянный угол.
* Теплофизические свойства: α, ν, β, λ - предполагаются зависящими от температуры (применятся интерполяционные формулы).
* Вещество: предусмотрено моделирование таких веществ как вода, воздух (без плавления), разные типы парафинов, а также вещества с любыми (но не зависящими от температуры) пользовательскими свойствами.

## Численный метод

* Используется метод конечных разностей на коллокационной сетке, где значения величин поля находятся и вычисляются в узлах сетки.
* Используются две модели плавления (их можно использовать и для течений без плавления): ALE - метод раздвижной стенки (Arbitrary Lagrangian-Eulerian) и EPM - метод энтальпийно-пористой среды (Enthalpy-Porous Media).
* Расчет конвективных членов производится по явной схеме "против потока (upwind)" второго порядка внутри области и первого порядка вблизи границ для сохранения устойчивости.
* Расчет диффузионных членов производится по неявной схеме с прогонками (метод Томаса, TDMA).
* Расчет давления производится с применением итераций на каждом вычислительном шаге, когда вычисляется приращение по времени; при этом в качестве экспериментов для модели ALE используется метод Якоби, а для EPM - метод Гаусса-Зейделя; а также применяется стабилизация Rhie-Chow и шахматная схема обхода узлов сетки.
* Для ALE применяется неравномерная сетка с увеличением шага от границ к центру по формуле гиперболического синуса.
* Для EPM для уменьшения времени расчетов используется равномерная квадратная сетка.
* В расчетах используются автоматически настраиваемые параметры временного шага, параметры управления итерационным процессом для давления, а также автоматические откаты при появлении признаков расходимости.
 * Прекращение расчетов задается когда достигается определенное время или определенный объем (или толщина) расплава.

## Дополнительные возможности

Для метода EPM можно моделировать включение твердых объектов (с плавлением и без) в жидкой среде, при этом используется метод эффективной теплоемкости. Предполагается что твердый объект с плавлением имеет температуру плавления $T_{\{cold}}$. Твердый объект без плавления имеет начальную температуру плавления $T_{\{cold}}$, а далее прогревается под воздействием теплопроводности.

> **Примечание:** Метод EPM предполагает, что имеется "интервал плавления", где $T_{\{cold}}$ меньше $T_{\{melt}}$ на небольшую величину (по умолчанию 0,01ºС)

Также в процессе решения происходит запоминание каждого кадра текущего состояния решения через определенные промежутки времени (История).

## Визуализация

Весь процесс расчетов отображается на одной странице экрана в виде набора параметров, полей и графиков. Для компактных устройств типа iPhone используется скроллинг. Управление процессом осуществляется с помощью контрольной панели манипулятором (мышь, тачпад), а также горячими клавишами. Интерфейс задан на английском языке и интуитивно понятен.

На странице визуализации имеются следующие зоны (см Примеры расчетов) -
> **примечание** - если используется выносная клавиатура, нажатие кнопок можно дублировать горячими клавишами, которые выделены синим цветом
* **контрольная панель:** здесь находятся кнопки 
1) Старта/Паузы - запуск/пауза процесса решения, 
2) Истории - сохранение кадров Истории в файл с использованием формата JSON или бинарного формата со сжатием. Загрузка кадров Истории из списка файлов,
> **примечание** - после загрузки файла можно продолжить расчет, однако требуется донастроить некоторые параметры, если сеанс расчета уже настроен на другую задачу
3) Сброса - устанавливается начальное состояние полей и переменных, за исключением времени, 
4) Диагностики - всплывающее окно с диагностическими параметрами и графиками с возможностью переключения содержания графиков и запуском итерационного процесса вычисления функции тока ω из уравнения Пуассона, 
5) Настройки - всплывающее окно с изменяемыми параметрами процесса решения, 
6) Ускорения - с целью ускорения вычислений выключает Область основного графика;
* **информационная зона:** состояние гравитации, состояние вектора скорости, параметры Решения, Области, Вещества, Процесса (с возможностью ручного регулирования шага по времени), Плавления;
* **управление графиками:** выбор графика, кнопка активизации плавления, кнопки управления режимами тепловой карты;
* **всплывающее окно просмотра Истории** с проигрывателем кадров (запуск/останов также по нажатию на пробел);
* **область основного графика:** тепловые карты (с опциональным наложением поля скорости и изолиниями) температуры, давления, линий тока с указанием направления потока; графики температуры в горизонтальных сечениях, тепловых потоков во времени на вертикальных границах; редактор включений твердых объектов;
* **всплывающее окно Диагностики** - см. комментарий к п4) Контрольной панели. 
* **всплывающее окно Настроек** - см. комментарий к п5) Контрольной панели и подробно в разделе [Входные параметры](#входные-параметры). 
> Пример начального экрана см. Примеры расчетов

## Структура проекта

Все файлы имеют внутри пометки типа MARK на английском, и достаточные комментарии на русском. Поскольку код пишется на английском - смысловая нагрузка отражена в названиях свойств и методов.

* Основная часть проекта размещена в папке Navier-Stokes, где размещены Модель данных, История, Решатель, Визуализатор.
* Модель данных содержит файлы: финальный класс решателя с публикуемыми переменными полей и параметров, вычисляемые параметры и свойства, моделируемые вещества со своими свойствами, глобальные параметры, тип нагрева, параметры для запоминания состояния.
* История содержит файлы с параметрами и методами управления запоминанием текущего состояния, включая сохранение и загрузку Истории на диск в различных форматах (со сжатием данных).
* Решатель с папками и файлами для управления решением уравнений.
* Визуализатор с папками и файлами для управления наглядным представлением выходных данных.

## Требования

Поскольку начало проекта - июнь 2025, код ориентирован на актуальные тогда ресурсы iOS и XCode, процессор М1. Проверялся на Mac и iPhone 15. 
Возможно код работает и на более ранних платформах, поскольку использованы только фреймворки Foundation, SwiftUI, Combine, UniformTypeIdentifiers.

## Установка и запуск расчета

Загрузить код на рабочий стол, открыть исполняемый файл, ввести аккаунт. Настроить релизную версию компилятора. Запустить программу. 
>**Примечания:** 1) Будет по умолчанию использоваться вещество Custom (по параметрам похожее на Эйкозан), время моделирования установлено на 60 секунд. Можно включить опцию Диагностики. 2) Режим сна на компьютере во время расчета не включается.

## Входные параметры

Изначально все требуемые для тестового расчета конвекции в квадратной полости параметры уже установлены. 

> **Примечание:** Для ввода параметров в текстовых и цифровых полях необходимо подтверждать изменения путем нажатия на возвтат каретки и далее на галочку.

Для требуемого пользовательского расчета используется панель Настройки, где можно изменить:
* **методы расчета** - модель (ALE или EPM, где устанавливается интервал плавнения), включить/выключить Плавление (и с какого шага), применить/отменить параллельные вычисления (конкурентные расчеты) для различных методов решения уравнений;
* **геометрия полости** - количество узлов сетки, длина и ширина полости, начальная толщина расплава (для метода EPM);
* **условия гравитации** - начальный угол, динамика изменения угла в день или в секунду, синхранизировать ли тепловые карты со временем моделирования или физическим временем (в случае плавления), величина магнитуды ускорения свободного падения может быть равной нулю при включении вынужденной конвекции;
* **временные параметры** - конечное время моделирования, конечная величина приращения относительного объема (толщины) расплава, временной шаг моделирования для занесения с Историю, масштаб времени плавления для ускорения расчетов (при этом точность расчетов падает), предельная величина приращения толщины расплава; 
* **управление процессом моделирования** - диапазон чисел Куранта для адаптации временного шага включая гибридную схему (не рекомендуется), допустимая погрешность при вычислении функции тока ω из уравнения Пуассона, параметры итерационного процесса для давления, лимиты длин массивов для Диагностики и Истории;
* **параметры объекта** - тип нагрева (температура или тепловой поток), величина нагрева, начальное распределение температуры в полости, условия для температуры при касании границы фазового перехода твердой правой стенки, выбор вещества для моделирования включая произвольное (у которого можно назначить любые параметры);
* **включение/выключение вынужденной конвекции** - включить/выключить сток вверху и внизу на левой границе (по умолчанию сток - на горизонтальных границах). Установить/редактировать: скорость вдува, превышение температуры вдува относительно установленной на горячей стенке, угол вдува, координаты участка вдува

## Выходные данные

Данные расчетов представлены в визуализаторе в основном в режиме реального времени, а также в ходе прокрутки Истории. Главные данные это тепловые карты температуры, давления, функции тока с наложением поля скоростей; график распределения температуры по горизонтальным сечениям; график зависимости от времени удельных тепловых потоков на вертикальных стенках. Имеются также данные Диагностики (не меняются в ходе прокрутки Истории).

## Примеры расчетов

Копии экранов (скриншоты) для экономии места приведены в английской версии. 

* **fig. 1** Начальное состояние после первого запуска программы: 
<img width="1256" height="973" alt="fig1" src="https://github.com/user-attachments/assets/78f96d9f-ffdc-49f3-8109-820fe5910b3f" />


* Состояние экрана визуализации для задачи на основе метода ALE "Тепловая конвекция (без плавления) внутри полости с Эйкозаном" с диагностическими графиками. Время моделирования - 90 секунд):

  1) **fig. 2** промежуточный вариант (t=60c) с линиями тока (тепловая карта - ТК).
  <img width="1256" height="973" alt="fig2" src="https://github.com/user-attachments/assets/17880486-2851-4e2e-a5a4-d2bd292ff906" />

  2) **fig. 3** поле температуры (тепловая карта).
  <img width="1256" height="973" alt="fig3" src="https://github.com/user-attachments/assets/18d796a6-9726-47eb-b35a-5c88ac235300" />
> **Комментарий:** Видно, что поле температуры почти однородно вследствие интенсивного перемешивания и лишь около вертикальных границ имеюся существенные градиенты. Линии тока носят замкнутый характер, что свидетельствует о ячеистой природе течения.

* Предыдущий пример, но на основе метода EPM: 
  1) **fig. 4** поле температуры
  <img width="1256" height="973" alt="fig4" src="https://github.com/user-attachments/assets/0b9f946d-9851-46d4-a6b9-312db8f4c71c" />

  2) **fig. 4а** тепловые потоки q(t) на стенках
  <img width="1256" height="973" alt="fig4a" src="https://github.com/user-attachments/assets/31523b26-594f-4e5f-b176-6d1a3f4580b8" />

> **Комментарий:** Здесь видно, что стационарный режим также пока не достигнут и имеется разница между потоками за счет зависимости теплопроводности от температуры; видна разница по затраченному процессором времени расчетов (**Spent**) по сравнению с методом ALE за счет оспользования невавномерной сетки. Следует также обратить внимание на различия в результатах и ​​диагностике, обусловленные использованием различных методов расчета давления.

* Пример ТК (метод ALE) плавления Воды с начальной толщиной расплава 0.3 от высоты: fig. 5

* Пример ТК (метод - EPM) плавления Воды с включением льда (на определённом этапе, в верхней части полости) и камня (с теплопроводностью льда, в центре полости) в область расплава с начальной толщиной расплава 0.3 от ширины области: fig. 6

* Пример ТК (EPM) плавления Эйкозана в невесомости с вдувом жидкой фазы и свободным стоком на левой границе: fig. 7

* Пример ТК (EPM) естественной конвекции в воздушной полости с углом наклона к горизонту в 30 градусов: fig. 8

> **Комментарий:** У воздуха амплитуда колебаний значений величин (что видно на графиках Диагностики) более выражена вследствие меньшей вязкости и плотности, чем у парафинов и воды, поэтому нестационарная фаза в расчетах больше. Однако уже просматривается тенденция к расположению изотерм перпендикулярно направлению гравитации.

## Производительность

Для увеличения производительности использовались следующие способы:

* все двумерные массивы полей переменных конвертированы в одномерные, а индексы узлов вычисляются по специальным формулам;
* в тяжелых циклах (внутренние точки) все (теперь одномерные) массивы вызываются с помощью указателей для избежания встроенного контроля границ массивов;
* во время расчета рекомендуется отключение визуализации Тепловой карты и диагностики;
* также предусмотрена организация параллельных вычислений (конкурентные вычисления для потоков) для основных процессов решения уравнений, однако из-за существенных накладных расходов при этом производительность на данных сетках меньше, чем без параллельных вычислений, и требуются дальнейшиу эксперименты.

## Ограничения модели

Рассматриваются только ламинарные течения в несжимаемой среде, числа подобия Re и Ra вычисляются по фактическим значениям переменных. Разность температур не должна превышать 40º (интерполяция температурных зависимостей физических параметров рассматриваемых веществ настроена на данный диапазон). 
Размерность сетки не тестировалась ниже чем 40х40 и мельче чем 300х300, а коэффициенты растяжения сетки не более чем 3.0 (влияет на устойчивость и сходимость). 
Точность вычислений ограничена типом Double.

## Лицензия

Текст MIT лицензии приведен в файле `LICENSE.md`.

## Контакты

Почта: `apezera@icloud.com`, `apezera@yandex.ru`. Буду рад замечаниям и предложениям.
<img width="1256" height="973" alt="fig4" src="https://github.com/user-attachments/assets/1041727c-ece8-4c8f-9bcc-47b2bd47f88a" />
