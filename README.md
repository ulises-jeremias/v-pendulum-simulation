<div align="center">
<h1>Pendulum Simulation in V</h1>

[vlang.io](https://vlang.io) |
[Docs](https://ulises-jeremias.github.io/v-pendulum-simulation) |
[Contributing](https://github.com/ulises-jeremias/v-pendulum-simulation/blob/main/CONTRIBUTING.md)

</div>
<div align="center">

[![Build Status][workflowbadge]][workflowurl]
[![Docs Validation][validatedocsbadge]][validatedocsurl]
[![License: MIT][licensebadge]][licenseurl]

![image](https://user-images.githubusercontent.com/17727170/142896769-22cc7af7-8f70-47ea-a6f0-f7218196593c.png)

</div>

## Run the examples

- Secuencial Simulation

```sh
$ v -gc boehm -prod secuencial.v
$ ./secuencial # execute ./secuencial -h for more info
```

- Parallel Simulation

```sh
$ v -gc boehm -prod parallel.v
$ ./parallel # execute ./parallel -h for more info
```

- Parallel Simulation with Graphic User Interface

```sh
$ v -gc boehm -prod animation.v
$ ./animation # execute ./animation -h for more info
```

- Full Parallel Simulation with Graphic User Interface and Image Output

```sh
$ v -gc boehm -prod full.v
$ ./full # execute ./full -h for more info
```

## Testing

To test the module, just type the following command:

```sh
$ v test .
```

[workflowbadge]: https://github.com/ulises-jeremias/v-pendulum-simulation/workflows/Build%20and%20Test%20with%20deps/badge.svg
[validatedocsbadge]: https://github.com/ulises-jeremias/v-pendulum-simulation/workflows/Validate%20Docs/badge.svg
[licensebadge]: https://img.shields.io/badge/License-MIT-blue.svg
[workflowurl]: https://github.com/ulises-jeremias/v-pendulum-simulation/commits/main
[validatedocsurl]: https://github.com/ulises-jeremias/v-pendulum-simulation/commits/main
[licenseurl]: https://github.com/ulises-jeremias/v-pendulum-simulation/blob/main/LICENSE
