'use client';
import { useState, useEffect } from 'react';

const productDetail = ({ params }: { params: { productId: string } }) => {
  const [product, setProduct] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    async function fetchProduct() {
      setLoading(true);
      try {
        const response = await fetch(`${process.env.NEXT_PUBLIC_API_GATEWAY}/product?id=${params.productId}`);
        if (!response.ok) {
          throw new Error('Failed to fetch product');
        }
        const product = await response.json();
        setProduct(product[0]);
      } catch (err) {
        setError('Failed to fetch product');
      } finally {
        setLoading(false);
      }
    }

    fetchProduct();
  }, [params.productId]);

  if (loading) {
    return <p>Loading product details...</p>;
  }

  if (error) {
    return <p>{error}</p>;
  }

  if (!product) {
    return <p>No product found.</p>;
  }

  return (
    <div className='flex min-h-screen flex-col p-24'>
      <h1 className='text-2xl font-semibold'>Product Description</h1>
      <h3 className={`mb-3 text-xl `}>{product.name}</h3>
      <p className={`m-0 max-w-[30ch] text-sm opacity-50`}>Price: {product.price}</p>
      <p className={`m-0 max-w-[30ch] text-sm opacity-50`}>Description: {product.description}</p>
      <p className={`m-0 max-w-[30ch] text-sm opacity-50`}>Category: {product.category}</p>
      <p className={`m-0 max-w-[30ch] text-sm opacity-50`}>Rating: {product.rating}</p>
      <p className={`m-0 max-w-[30ch] text-sm opacity-50`}>Reviews: {product.numReviews}</p>
      <p className={`m-0 max-w-[30ch] text-sm opacity-50`}>Stock: {product.countInStock}</p>
    </div>
  );
};

export default productDetail;
