import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class CreateListing extends StatefulWidget {
  const CreateListing({super.key});

  @override
  State<CreateListing> createState() => _CreateListingState();
}

class _CreateListingState extends State<CreateListing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sell an Item"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Upload Placeholder
            GestureDetector(
              onTap: () {
                // Logic to pick image from gallery
              },
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[400]!, style: BorderStyle.solid),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 50, color: AppColors.primary),
                    SizedBox(height: 10),
                    Text("Upload Item Image", style: TextStyle(color: AppColors.primary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Input Fields
            _buildLabel("Item Name"),
            _buildTextField("e.g. Scientific Calculator"),
            
            const SizedBox(height: 15),
            _buildLabel("Price (ETB)"),
            _buildTextField("e.g. 500", keyboardType: TextInputType.number),
            
            const SizedBox(height: 15),
            _buildLabel("Description"),
            _buildTextField("Condition, location, etc.", maxLines: 3),

            const SizedBox(height: 30),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // Logic to save listing
                  Navigator.pop(context);
                },
                child: const Text(
                  "Post Listing",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
    );
  }

  Widget _buildTextField(String hint, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextField(
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
      ),
    );
  }
}