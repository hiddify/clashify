import 'package:clashify/core/core_providers.dart';
import 'package:clashify/data/data_providers.dart';
import 'package:clashify/features/proxies/notifier/notifier.dart';
import 'package:clashify/gen/assets.gen.dart';
import 'package:clashify/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';

// HACK: temporary
final connectionSpeed = StreamProvider(
  (ref) {
    return ref.read(Facade.clash).watchTraffic().map(
      (event) {
        print("traffic innnn $event");
        return event.match(
          (l) => throw l,
          (r) => r,
        );
      },
    );
  },
);

class ConnectionDetailsBody extends HookConsumerWidget {
  const ConnectionDetailsBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Row(
      children: [
        Expanded(child: ConnectionDelay()),
        Expanded(child: ConnectionButton()),
        Expanded(child: ConnectionSpeed()),
      ],
    );
  }
}

class ConnectionButton extends HookConsumerWidget {
  const ConnectionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(Core.translations);
    final state = ref.watch(ProxiesNotifier.provider);
    final notifier = ref.watch(ProxiesNotifier.provider.notifier);

    final Color connectionLogoColor = state.isSystemProxy
        ? const Color.fromRGBO(89, 140, 82, 1)
        : const Color.fromRGBO(74, 77, 139, 1);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                blurRadius: 24,
                color: connectionLogoColor.withOpacity(0.5),
              ),
            ],
          ),
          width: 124,
          height: 124,
          child: Material(
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () async {
                if (state.isSystemProxy) {
                  await notifier.clearSystemProxy();
                } else {
                  await notifier.setSystemProxy();
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(26),
                child: Assets.images.logo.svg(
                  colorFilter: ColorFilter.mode(
                    connectionLogoColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
        const Gap(8),
        if (state.isSystemProxy)
          Text(t.home.connected.titleCase)
        else
          Text(t.home.tapToConnect.sentenceCase),
      ],
    );
  }
}

class ConnectionDelay extends HookConsumerWidget {
  const ConnectionDelay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(Core.translations);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.speed),
        Text(t.home.delay),
      ],
    );
  }
}

class ConnectionSpeed extends HookConsumerWidget {
  const ConnectionSpeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speed = ref.watch(connectionSpeed);

    return speed.maybeWhen(
      data: (traffic) {
        return _build(
          formatByteSize(traffic.upload),
          formatByteSize(traffic.download),
        );
      },
      orElse: () {
        return _build("...", "...");
      },
    );
  }

  Widget _build(String up, String down) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.upload),
            Text(up),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.download),
            Text(down),
          ],
        ),
      ],
    );
  }
}
