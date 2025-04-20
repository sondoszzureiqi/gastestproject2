/*import 'package:flutter/material.dart';
import 'package:gastestproject/widgets/TRoundedConatainer.dart';
import 'package:gastestproject/theme/app_theme.dart';
import 'package:gastestproject/theme/sizes.dart';

class ToOrderListItems extends StatelessWidget {
  const ToOrderListItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TRoundedContainer(
        showBorder: true,
        padding: const EdgeInsets.all(TSizes.md),
        backgroundColor: Colors.white,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.95,
          height: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Row 1
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_shipping, color: AppTheme.primaryColor, size: 24),
                      const SizedBox(width: TSizes.spaceBtwItems),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order',
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: AppTheme.primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '07 Nov 2024',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: AppTheme.primaryColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 15),

              /// Row 2
              Row(
                children: [
                  const Icon(Icons.tag, color: AppTheme.primaryColor, size: 24),
                  const SizedBox(width: TSizes.spaceBtwItems),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order',
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: AppTheme.primaryColor,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '#256f2f',
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: AppTheme.primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} */