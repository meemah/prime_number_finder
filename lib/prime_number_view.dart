import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prime_number_finder/prime_number_viewmodel.dart';

class PrimeNumberView extends HookConsumerWidget {
  const PrimeNumberView({super.key});

  @override
  Widget build(BuildContext context, ref) {
    var numberController = useTextEditingController();
    var scrollController = useScrollController();
    var primeViewModel = ref.watch(findPrimeNumberViewModel);
    List<int> primeNumbers = primeViewModel.value ?? [];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0).copyWith(bottom: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 40, bottom: 20),
                child: Text(
                  "Find all prime numbers:",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
                ),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    ref.read(findPrimeNumberViewModel.notifier).resetValue(),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    isCollapsed: true,
                    hintText: "Enter a maximum number",
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepOrange),
                        borderRadius: BorderRadius.all(Radius.circular(8)))),
                controller: numberController,
              ),
              const SizedBox(
                height: 40,
              ),
              GestureDetector(
                onTap: () {
                  int maximumNumber = int.tryParse(numberController.text) ?? 0;
                  if (maximumNumber > 0) {
                    showDialog(
                        context: context,
                        builder: (ctx) {
                          return Dialog(
                            backgroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                            child: Wrap(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                          ref
                                              .read(findPrimeNumberViewModel
                                                  .notifier)
                                              .searchListBySpawn(maximumNumber);
                                        },
                                        child: const Text("Use Spawn Method"),
                                      ),
                                      const SizedBox(
                                        height: 30,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                          ref
                                              .read(findPrimeNumberViewModel
                                                  .notifier)
                                              .searchListByCompute(
                                                  maximumNumber);
                                        },
                                        child: const Text("Use Compute Method"),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                  }
                },
                child: Container(
                  height: 52,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.deepOrangeAccent,
                  ),
                  child: Center(
                    child: primeViewModel.isLoading
                        ? const CircularProgressIndicator.adaptive()
                        : const Text(
                            "Search",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              if (primeViewModel.hasValue) ...[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Scrollbar(
                      controller: scrollController,
                      thickness: 5,
                      radius: const Radius.circular(10),
                      thumbVisibility: true,
                      child: GridView.builder(
                          controller: scrollController,
                          itemCount: primeNumbers.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  childAspectRatio: 3,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 10,
                                  crossAxisCount: 4),
                          itemBuilder: (ctx, index) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.deepOrange,
                                ),
                              ),
                              child:
                                  Center(child: Text("${primeNumbers[index]}")),
                            );
                          }),
                    ),
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
