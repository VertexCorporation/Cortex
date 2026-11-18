import 'package:cortex/notifications/extrovert/service.dart';
import 'package:cortex/tasks/service.dart';
import 'package:cortex/tasks/task.dart';
import 'package:cortex/app.dart';
import 'package:cortex/appbar.dart';
import 'package:cortex/design.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _service = TaskService();
  List<CortexTask> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tasks = await _service.load();
    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _loading = false;
    });
  }

  Future<void> _persist() => _service.save(_tasks);

  Future<void> _addTask() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    DateTime? reminder;
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, refresh) => AlertDialog(
          title: Text(l10n.taskNewTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(hintText: l10n.taskInputHint),
                onSubmitted: (value) => Navigator.pop(dialogContext, value),
              ),
              TextButton.icon(
                onPressed: () async {
                  final now = DateTime.now();
                  final date = await showDatePicker(
                    context: dialogContext,
                    initialDate: now,
                    firstDate: now,
                    lastDate: now.add(const Duration(days: 3650)),
                  );
                  if (date == null || !dialogContext.mounted) return;
                  final time = await showTimePicker(
                    context: dialogContext,
                    initialTime: TimeOfDay.fromDateTime(now),
                  );
                  if (time == null) return;
                  refresh(
                    () => reminder = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    ),
                  );
                },
                icon: const Icon(Icons.notifications_outlined),
                label: Text(
                  reminder == null
                      ? l10n.taskReminderAdd
                      : '${MaterialLocalizations.of(context).formatShortDate(reminder!)} ${TimeOfDay.fromDateTime(reminder!).format(context)}',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, controller.text),
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    final cleanTitle = title?.trim() ?? '';
    if (cleanTitle.isEmpty || !mounted) return;

    int? notificationId;
    var reminderScheduled = false;
    if (reminder != null && reminder!.isAfter(DateTime.now())) {
      final notifications = context.read<ExtrovertNotificationService>();
      final allowed = await notifications.requestTaskReminderPermission();
      if (allowed) {
        notificationId = DateTime.now().microsecondsSinceEpoch & 0x7fffffff;
        try {
          await notifications.scheduleTaskReminder(
            notificationId: notificationId,
            title: cleanTitle,
            scheduledAt: reminder!,
          );
          reminderScheduled = true;
        } catch (_) {
          notificationId = null;
        }
      }
    }

    setState(
      () => _tasks = [
        CortexTask(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: cleanTitle,
          dueAt: reminder,
          notificationId: notificationId,
        ),
        ..._tasks,
      ],
    );
    await _persist();
    if (reminder != null && !reminderScheduled && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.taskReminderPermissionNeeded)),
      );
    }
  }

  Future<void> _toggle(CortexTask task) async {
    if (!task.isDone && task.notificationId != null) {
      await context.read<ExtrovertNotificationService>().cancelTaskReminder(
        task.notificationId!,
      );
    }
    setState(
      () => _tasks = _tasks
          .map(
            (item) =>
                item.id == task.id ? item.copyWith(isDone: !item.isDone) : item,
          )
          .toList(),
    );
    await _persist();
  }

  Future<void> _delete(CortexTask task) async {
    if (task.notificationId != null) {
      await context.read<ExtrovertNotificationService>().cancelTaskReminder(
        task.notificationId!,
      );
    }
    setState(() => _tasks.removeWhere((item) => item.id == task.id));
    await _persist();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = l10n.tasksTitle;
    final inverted = AppColors.primaryColor.inverted;
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: CortexAppBar(
        leadingMode: CortexLeadingMode.axon,
        titleText: title,
        actions: [
          IconButton(
            tooltip: l10n.add,
            onPressed: _addTask,
            icon: SvgPicture.asset(
              'assets/icons/add.svg',
              width: CortexDesign.icon,
              height: CortexDesign.icon,
              colorFilter: ColorFilter.mode(inverted, BlendMode.srcIn),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: _loading
              ? const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                )
              : _tasks.isEmpty
              ? _buildEmptyState(inverted, l10n)
              : ListView(
                  padding: EdgeInsets.fromLTRB(
                    CortexDesign.gutter(width),
                    MediaQuery.paddingOf(context).top + kToolbarHeight + 20,
                    CortexDesign.gutter(width),
                    32,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Text(
                        l10n.tasksIntro,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: inverted.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                    for (final task in _tasks) ...[
                      _buildTaskCard(task, inverted, l10n),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color inverted, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.senaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(CortexDesign.cardRadius),
            ),
            child: Icon(
              Icons.checklist_rounded,
              size: 36,
              color: AppColors.senaryColor,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.tasksEmptyTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: inverted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tasksEmptyBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: inverted.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 22),
          _addTaskButton(inverted, l10n),
        ],
      ),
    );
  }

  Widget _buildTaskCard(
    CortexTask task,
    Color inverted,
    AppLocalizations l10n,
  ) {
    final dueAt = task.dueAt;
    return AnimatedContainer(
      duration: CortexDesign.motion,
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(CortexDesign.radius),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 8, 12),
        child: Row(
          children: [
            Semantics(
              button: true,
              checked: task.isDone,
              label: task.title,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _toggle(task),
                child: AnimatedContainer(
                  duration: CortexDesign.motion,
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isDone
                        ? AppColors.senaryColor
                        : Colors.transparent,
                    border: Border.all(
                      color: task.isDone
                          ? AppColors.senaryColor
                          : inverted.withValues(alpha: 0.28),
                      width: 1.5,
                    ),
                  ),
                  child: task.isDone
                      ? const Icon(
                          Icons.check_rounded,
                          size: 17,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: CortexDesign.motion,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: inverted.withValues(alpha: task.isDone ? 0.45 : 1),
                      decoration: task.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                    child: Text(task.title),
                  ),
                  if (dueAt != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      '${MaterialLocalizations.of(context).formatShortDate(dueAt)} · ${TimeOfDay.fromDateTime(dueAt).format(context)}',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: inverted.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              tooltip: l10n.delete,
              onPressed: () => _delete(task),
              icon: SvgPicture.asset(
                'assets/icons/delete.svg',
                width: CortexDesign.iconSmall,
                height: CortexDesign.iconSmall,
                colorFilter: ColorFilter.mode(
                  inverted.withValues(alpha: 0.45),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addTaskButton(Color inverted, AppLocalizations l10n) {
    return Material(
      color: inverted,
      borderRadius: BorderRadius.circular(CortexDesign.radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(CortexDesign.radius),
        onTap: _addTask,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 19, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              Text(
                l10n.add,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
