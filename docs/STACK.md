# Stack

Written at stage 2 (`decide`). Every area in pitwall's `decide.areas` appears in one of the tables below. Versions are read from the package registry at decision time, never from memory.

## Decisions

| Area | Choice | Version | Source | ADR |
| --- | --- | --- | --- | --- |
| Platform and runtime | Windows 11 x64, .NET 10 LTS, публикация self-contained | 10.0.15 | https://endoflife.date/api/dotnet.json прочитано 2026-11-13 (релиз 2026-11-10, поддержка до 2028-11-14) | ADR-0003 |
| Language | C# | - | - | ADR-0003 |
| Framework | Windows Forms из состава .NET 10 | 10.0.15 | https://endoflife.date/api/dotnet.json прочитано 2026-11-13 (релиз 2026-11-10) | ADR-0003 |
| Data model | Список напоминаний двух видов в одном JSON-файле со schemaVersion в %APPDATA%\move-reminder | - | - | ADR-0001 |
| Hosting and staging | GitHub Releases, установщик NSIS на пользователя, сборка в GitHub Actions; staging: локальная сборка | 3.13 | https://nsis.sourceforge.io/Download прочитано 2026-11-13 (релиз 2026-09-27) | ADR-0002 |
| Platform and runtime | .NET SDK, закреплён в global.json (rollForward latestPatch) | 10.0.404 | https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/10.0/releases.json прочитано 2026-11-13 (latest-sdk) | ADR-0003 |
| CI/CD | actions/checkout, actions/setup-dotnet, actions/upload-artifact | v7.0.1, v6.1.0, v7.0.2 | https://api.github.com/repos/actions/checkout/releases/latest (и то же для setup-dotnet, upload-artifact) прочитано 2026-11-13 (релизы 2026-07-20, 2026-11-03, 2026-10-07) | ADR-0002 |
| Test strategy | xunit.v3 | 4.0.3 | https://api.nuget.org/v3/registration5-gz-semver2/xunit.v3/index.json прочитано 2026-11-13 (релиз 2026-11-09, Apache-2.0) | - |
| Test strategy | xunit.runner.visualstudio | 4.0.1 | https://api.nuget.org/v3/registration5-gz-semver2/xunit.runner.visualstudio/index.json прочитано 2026-11-13 (релиз 2026-10-09, Apache-2.0) | - |
| Test strategy | Microsoft.NET.Test.Sdk | 18.12.0 | https://api.nuget.org/v3/registration5-gz-semver2/microsoft.net.test.sdk/index.json прочитано 2026-11-13 (релиз 2026-11-11, MIT) | - |
| Test strategy | Microsoft.Extensions.TimeProvider.Testing (FakeTimeProvider) | 11.0.0 | https://api.nuget.org/v3/registration5-gz-semver2/microsoft.extensions.timeprovider.testing/index.json прочитано 2026-11-13 (релиз 2026-11-10, MIT) | - |
| Lint and format | Microsoft.CodeAnalysis.BannedApiAnalyzers | 5.6.0 | https://api.nuget.org/v3/registration5-gz-semver2/microsoft.codeanalysis.bannedapianalyzers/index.json прочитано 2026-11-13 (релиз 2026-07-02, MIT) | - |

Source links the registry page the version was read from, with the date it was read. A choice without a version has `-` in both columns, and a two-way choice has `-` for its ADR.

## Models, prices and limits

Проект не вызывает ни AI-моделей, ни платных API, поэтому конфиг для моделей, цен и лимитов не нужен. Когда появится анализ через Claude (позже, не в первом релизе), область «AI models and external APIs» решается заново, и этот раздел назовёт один файл конфигурации.

## Two-way decisions

Picked by the agent, accepted by the owner as a list. An area that does not apply is listed as `Not needed`, with the reason.

| Area | Choice | Why, in one line |
| --- | --- | --- |
| Database | Not needed | Настройки лежат в одном JSON-файле (ADR-0001), базы нет |
| Auth | Not needed | Один локальный пользователь, аккаунтов нет |
| API | Not needed | Нет сервера и внешних API, приложение не выходит в сеть |
| Observability | Not needed | Владелец решил: ни телеметрии, ни логов; отладка по сценариям QA |
| AI models and external APIs | Not needed | В первом релизе их нет; Claude появится позже |
| Repository layout | Один репозиторий, одно решение .sln, код в src/, тесты в tests/ | Одно приложение на одном языке |
| Monolith or services | Монолит: один процесс в трее | Сервисам нечего делить |
| Folder structure and module boundaries | src/MoveReminder.Core (расписание, модель, хранение; чистый net10.0 без WinForms), src/MoveReminder.App (трей, окно, уведомления, события ОС, автозапуск), tests/MoveReminder.Core.Tests | Логика напоминаний тестируется без Windows UI, а границу держит компилятор |
| Architecture patterns | Чистое ядро планировщика со временем через TimeProvider; App передаёт ядру события ОС и нажатия и показывает его решения | Сон, блокировка и «через час» проверяются тестами на фейковых часах без ожидания |
| Client state | Таймеры и пауза в памяти процесса, на диск пишутся только настройки | Хранятся только настройки, как решено в discovery |
| UI kit | Стандартные контролы WinForms без сторонних библиотек | Окно настроек маленькое, лишние зависимости не нужны |
| Lint and format | dotnet format и встроенные анализаторы .NET, предупреждения как ошибки, правила в .editorconfig; BannedApiAnalyzers для запретов | Всё встроено в SDK, запреты API проверяет анализатор |
| Test strategy | xUnit для ядра на FakeTimeProvider; трей и уведомления проверяются ручным QA по сценариям | Логику покрывают автотесты, системное поведение Windows проверяет владелец как пользователь |
| CI/CD | GitHub Actions на windows-latest: scripts/gate --full (формат, сборка, тесты); scripts/build делает self-contained publish и установщик NSIS | Стандартные раннеры бесплатны для публичного репозитория (ADR-0002) |
| i18n | Русский интерфейс, строки в ресурсах .resx | Главный пользователь говорит по-русски; английский добавляется позже без переписывания |
| Accessibility | Стандартные контролы с доступными именами, всё доступно с клавиатуры | WinForms даёт это почти бесплатно; отдельного аудита на уровне lite нет |
